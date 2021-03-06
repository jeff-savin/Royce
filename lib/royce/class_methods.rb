module Royce
  module ClassMethods
    def self.included includer
      includer.class_eval do

        # Add relations to including class
        has_many :role_connectors, as: :roleable, class_name: 'Royce::Connector'
        has_many :roles, through: :role_connectors, class_name: 'Royce::Role'

        # Add class method to return all possible roles
        def self.available_roles
          self.available_role_names.map{ |name| Role.find_or_create_by(name: name) }
        end

        # Add scopes to including class
        # User.admins
        # User.editors
        if includer.superclass == ActiveRecord::Base
          includer_class_name = includer.model_name.to_s.underscore.pluralize
        else
          includer_class_name = includer.superclass.model_name.to_s.underscore.pluralize
        end
        available_role_names.each do |role_name|
          scope role_name.pluralize, -> { Role.find_by(name: role_name).send includer_class_name.to_sym }
        end

      end

      # Be able to search some_role.users and get back instnaces of User
      # Royce::Role.find_by(name, 'admin').users
      Royce::Role.class_eval do
        if includer.superclass == ActiveRecord::Base
          has_many includer.model_name.to_s.underscore.pluralize.to_sym, through: :connectors, source: :roleable, source_type: includer.model_name.to_s
        else
          has_many includer.superclass.model_name.to_s.underscore.pluralize.to_sym, through: :connectors, source: :roleable, source_type: includer.superclass.model_name.to_s
        end
      end

    end
  end
end
