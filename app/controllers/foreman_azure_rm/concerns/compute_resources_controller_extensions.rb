module ForemanAzureRm
  module Concerns
    module ComputeResourcesControllerExtensions
      include Api::Version2
      include Foreman::Controller::Parameters::ComputeResource
      extend ::Apipie::DSL::Concern
      update_api(:create, :update) do
        param :compute_resource, Hash do
          # Not adding :tenant as already specified in core.
          param :app_ident, String, :desc => N_("Client ID for AzureRm")
          param :secret_key, String, :desc => N_("Client Secret for AzureRm")
          param :sub_id, String, :desc => N_("Subscription ID for AzureRm")
          param :cloud, String, :desc => N_("Cloud")
        end
      end

      def available_resource_groups
        compute_resource = ComputeResource.find_by_id(params[:id])
        @available_resource_groups = compute_resource.available_resource_groups
        render :available_resource_groups, :layout => 'api/v2/layouts/index_layout'
      end

      def available_sizes
        compute_resource = ComputeResource.find_by_id(params[:id])
        @available_sizes = compute_resource.vm_sizes(params[:region_id])
        render :available_sizes, :layout => 'api/v2/layouts/index_layout'
      end

      def available_subnets
        compute_resource = ComputeResource.find_by_id(params[:id])
        @available_subnets = compute_resource.available_subnets
        render :available_subnets, :layout => 'api/v2/layouts/index_layout'
      end

      def available_vnets
        compute_resource = ComputeResource.find_by_id(params[:id])
        @available_vnets = compute_resource.available_vnets
        render :available_vnets, :layout => 'api/v2/layouts/index_layout'
      end

      def action_permission
        resource_groups = 'available_resource_groups'
        sizes = 'available_sizes'
        subnets = 'available_subnets'
        vnets = 'available_vnets'
        case params[:action]
          when resource_groups, sizes, subnets, vnets
            :view
          else
            super
        end
      end
    end
  end
end
