# backtick_javascript: true

# Storable concern - provides LocalStorage functionality
module Storable
  def local_storage
    @local_storage ||= JS::Proxy.new(`localStorage`)
  end

  def storage_get(key)
    stored = local_storage.get_item(key)
    return [] unless stored

    `JSON.parse(#{stored})`
  end

  def storage_set(key, data)
    json = `JSON.stringify(#{data.to_n})`
    local_storage.set_item(key, json)
  end
end
