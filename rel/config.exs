use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: :dev

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"=]}r5pQUHPyd8[@5v/:c$l&cM<oR_CiPG::wh4dT|>(j(n^.YE)b:Rww:2z.eo$9"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"4$UGcH]SECQ~JjZC;z1zP9FI>idEww.$M3:?C;k_~YHK._ej?:Phcx78_[F^(&b~"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :sample_plug_app do
  set version: current_version(:sample_plug_app)
  set output_dir: './releases/sample_plug_app'
end

