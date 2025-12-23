class BaseService
  @name = "base_service"
  @enabled = true
  @root_path = File.dirname(__FILE__).split(File::SEPARATOR)[-2..].join(File::SEPARATOR)

  def self.provision(config)
    # Provision base services using podman compose
    config.vm.provision "base services", type: "shell", 
      run: "never",
      privileged: false,
      keep_color: true,
      path: "#{@root_path}/provision.sh",
      args: "up"

    # Check if all base services are under normal status
    config.vm.provision "health check", type: "shell", 
      run: "never",
      privileged: false,
      keep_color: true,
      path: "#{@root_path}/provision.sh",
      args: "ps"
  end
end
