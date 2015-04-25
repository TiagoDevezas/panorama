module SourcesHelper
  def cache_key_for_sources
    count = Source.count
    "sources/all-#{count}"
  end
end
