module JsRender
  module Utils
    # based on rails camelize
    Camelize = ->(key) do
      key = key.sub(/^(?:(?=\b|[A-Z_])|\w)/) { $&.downcase }
      key.gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }
    end
  end
end
