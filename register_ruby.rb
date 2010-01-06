require 'win32/registry'
require 'Win32API'

# Where is your ruby installed
main_path = "F:\\Applications\\Ruby\\bin"

#Prepare
type_path, type_ext, path, ext = nil, nil, nil, nil

# Read PATH
Win32::Registry::HKEY_LOCAL_MACHINE.open('System\CurrentControlSet\Control\Session Manager\Environment') do |reg|
	type_path, path = reg.read('Path')
	type_ext, ext = reg.read('PATHEXT')
end

Win32::Registry::HKEY_LOCAL_MACHINE.open('System\CurrentControlSet\Control\Session Manager\Environment', Win32::Registry::KEY_WRITE) do |reg|
	#If path does not contain ruby, add it
	if not path[main_path]
		path = "#{main_path};#{path}"
		reg.write('Path', type_path, path)
	end

	#And register Ruby extension .RB
	if not ext[".RB"]
		ext = ".RB;#{ext}"
		reg.write('PATHEXT', type_ext, ext)
	end
end

#Refresh environment variables
SendMessageTimeout = Win32API.new('user32', 'SendMessageTimeout', 'LLLPLLP', 'L') 
HWND_BROADCAST = 0xffff
WM_SETTINGCHANGE = 0x001A
SMTO_ABORTIFHUNG = 2
result = 0
SendMessageTimeout.call(HWND_BROADCAST, WM_SETTINGCHANGE, 0, 'Environment', SMTO_ABORTIFHUNG, 5000, result)
