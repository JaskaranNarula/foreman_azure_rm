module ForemanAzureRM
  class Engine < ::Rails::Engine
    engine_name 'foreman_azure_rm'

    initializer 'foreman_azure_rm.register_plugin', :before => :finisher_hook do
      Foreman::Plugin.register :foreman_azure_rm do
        requires_foreman '>= 1.14'
        compute_resource ForemanAzureRM::AzureRM
      end
    end

    initializer 'foreman_azure_rm.register_gettext', after: :load_config_initializers do
      locale_dir = File.join(File.expand_path('../../../', __FILE__), 'locale')
      locale_domain = 'foreman_azure_rm'
      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end

    initializer 'foreman_azure_rm.assets.precompile' do |app|
      app.config.assets.precompile += %w(foreman_azure_rm/azure_rm_size_from_location.js)
    end

    initializer 'foreman_azure_rm.configure_assets', :group => :assets do
      SETTINGS[:foreman_azure_rm] = { :assets => { :precompile => ['foreman_azure_rm/azure_rm_size_from_location.js']}}
    end

    config.to_prepare do
      require 'fog/azurerm'

      require 'fog/azurerm/models/compute/server'
      require File.expand_path(
          '../../../app/models/concerns/fog_extensions/azurerm/server',
          __FILE__
      )
      Fog::Compute::AzureRM::Server.send(:include, FogExtensions::AzureRM::Server)

      require 'fog/azurerm/models/compute/servers'
      require File.expand_path(
          '../../../app/models/concerns/fog_extensions/azurerm/servers',
          __FILE__
      )
      Fog::Compute::AzureRM::Servers.send(:include, FogExtensions::AzureRM::Servers)

      require 'fog/azurerm/compute'
      require File.expand_path(
          '../../../app/models/concerns/fog_extensions/azurerm/compute',
          __FILE__
      )
      Fog::Compute::AzureRM::Real.send(:include, FogExtensions::AzureRM::Compute)

      ::HostsController.send(:include, ForemanAzureRM::Concerns::HostsControllerExtensions)
    end
  end
end