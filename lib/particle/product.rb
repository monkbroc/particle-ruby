require 'particle/model'

module Particle

  # Domain model for one Particle product
  class Product < Model
    ID_REGEX = /^\d+$/

    def initialize(client, attributes)
      super(client, attributes)

      attributes = attributes.to_s if attributes.is_a?(Integer)

      if attributes.is_a? String
        if attributes =~ ID_REGEX
          @attributes = { id: attributes }
        else
          @attributes = { slug: attributes }
        end
      else
        # Listing all devices returns partial attributes so check if the
        # device was fully loaded or not
        @fully_loaded = true if attributes.key?(:name)
      end
    end

    attribute_reader :name, :description, :platform_id, :type, :hardware_version,
      :config_id,
      # below here are new attributes that appeared with API change
      :subscription_id, :mb_limit, :groups, :settings, :org

    def get_attributes
      @loaded = @fully_loaded = true
      @attributes = @client.product_attributes(self)
    end

    def firmware(target)
      @client.product_firmware(self, target)
    end

    def upload_firmware(version, title, binary, desc = nil)
      params = { version: version, title: title, binary: binary, description: desc }
      @client.upload_product_firmware(self, params)
    end

    def id
      get_attributes unless @attributes[:id]
      @attributes[:id]
    end

    def slug
      get_attributes unless @attributes[:slug]
      @attributes[:slug]
    end

    def organization
      get_attributes unless @attributes[:organization] || @attributes[:org]
      @attributes[:organization] || @attributes[:org]
    end

    def id_or_slug
      @attributes[:id] || @attributes[:slug]
    end

    def self.list_path
      "v1/products"
    end

    def path
      "/v1/products/#{id_or_slug}"
    end

    def firmware_path(version)
      "/v1/products/#{id_or_slug}/firmware/#{version}"
    end

    def firmware_upload_path
      "/v1/products/#{id_or_slug}/firmware"
    end
  end
end
