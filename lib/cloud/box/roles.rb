module Cloud::Box::Roles
  def self.included(base)
    base.extend ClassMethods
  end

  def roles
    @roles ||= self.class.roles.map do |role|
      role.new(self)
    end
  end

  module ClassMethods
    def roles(*role_names)
      @role_names = Array(role_names)
      unless @role_names.empty?
        @roles = @role_names.map do |name|
          Cloud::Roles.find(name)
        end
      end
      @roles
    end
  end
end