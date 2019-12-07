def read_ip_address(vm)
    command = "ip a | grep 'inet' | grep -v '127.0.0.1' | grep -v '::1/128' | cut -d: -f2 | awk '{ print $2 }' | cut -f1 -d\"/\""
    result  = ""

#    puts "Processing #{ vm.name } ... "

    begin
      # sudo is needed for ifconfig
      vm.communicate.sudo(command) do |type, data|
        result << data if type == :stdout
      end
#      puts "Processing #{ vm.name } ... success"
    rescue
      result = "# NOT-UP"
#      puts "Processing #{ vm.name } ... not running"
    end

    result = result.chomp.split("\n").select { |hash| hash != "" }

    vm_host_only_interfaces = []
    vm.provider.driver.read_network_interfaces().each_value do |iface|
      if iface[:type] == :hostonly then
        vm_host_only_interfaces.push(iface[:hostonly])
      end
    end

    vm_host_only_interfaces = vm.provider.driver.read_host_only_interfaces().select { |iface| vm_host_only_interfaces.include? iface[:name]  }

    ip = "# NO-IP"
    result.each do |vm_ip|
      vm_host_only_interfaces.each do |iface|
        if vm_ip[/[0-9]+.[0-9]+.[0-9]+/] = iface[:ip][/[0-9]+.[0-9]+.[0-9]+/] then 
          ip = vm_ip
        end
      end
    end

    ip
end
