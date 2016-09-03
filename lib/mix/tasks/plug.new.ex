defmodule Mix.Tasks.Plug.New do
  use Mix.Task

  @shortdoc "Generate a simple plug app"

  @moduledoc """
  Generate a simple plug app

      $ mix plug.new ./new_app

  The default router is inflected from the application
  name.
  """
  def run(args) do
    %{files: files, context: context, dir: dir} = parse_args(args)
    files |> Enum.each(&render(&1, context, dir))
  end

  defp render(%{template: template, target: target}, context, dir) do
    Path.expand("../../../#{template}", __DIR__)
    |> EEx.eval_file(context)
    |> output(dir, target)
  end

  defp output(contents, dir, rel_path) do
    Path.expand(rel_path, dir)
    |> Mix.Generator.create_file(contents)
  end

  defp parse_args(args) do

    switches = [template: :string]
    {opts, args, _} = OptionParser.parse(args, switches: switches, aliases: [t: :template])

    default_opts = [template: :default]
    opts = Keyword.merge(default_opts, opts)

    with app_path <- Enum.at(args, 0),
         app_name <- Path.basename(app_path),
         module <- inflect(app_name),
         template <- opts[:template] do
      %{
        files: [
          %{template: "priv/templates/#{template}/new/app.ex", target: "lib/#{app_name}.ex"},
          %{template: "priv/templates/#{template}/new/router.ex", target: "lib/#{app_name}/router.ex"}
        ],
        context: [module: module],
        dir: app_path
      }
    end
  end

  defp inflect(name) do
    name
    |> String.split("_")
    |> Enum.map(&String.capitalize(&1))
    |> Enum.join("")
  end

end
