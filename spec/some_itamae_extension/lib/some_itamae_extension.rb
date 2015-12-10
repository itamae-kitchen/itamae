module SomeItamaeExtension
  def itamae_extended
  end
end

Itamae::Runner.extend(SomeItamaeExtension)
