
property main_disk_list : {}
property main_disk_listfix : {}
property main_ntfs_dev : {}
property main_ntfs_uuid : {}
property main_ntfs_vol : {}
property main_ntfs_mnt : {}


--made by pref startup
property notauto_mount_disk : {}
property auto_mount_disk : {}
property auto_pref_dis : {}

--made by mount_notauto
property nice_mount_names : {}
property chos_mount_dev : {}


app_startup()


on app_startup()
	
	set chos_mount_dev to {}
	set nice_mount_names to {}
	set auto_pref_dis to {}
	set auto_mount_disk to {}
	set notauto_mount_disk to {}
	set main_ntfs_dev to {}
	set main_ntfs_uuid to {}
	set main_ntfs_vol to {}
	set main_ntfs_mnt to {}
	set main_disk_list to {}
	set main_disk_listfix to {}
	
	disk_startup()
	pref_startup()
	mount_startup()
	
end app_startup





on disk_startup()
	
	make_unix_disks()
	make_ntfs_disks()
	make_ntfs_uuid()
	make_ntfs_vol()
	make_ntfs_mnt()
	
	
end disk_startup






on pref_startup()
	
	check_prefs()
	read_prefs()
	
end pref_startup






on mount_startup()
	
	set num_math_con to count of items in notauto_mount_disk
	
	mount_auto()
	
	mount_notauto()
	
	
	
	
end mount_startup




on mount_auto()
	
	set item_count to "1" as number
	
	set num_math_loop to count of items in auto_mount_disk
	
	repeat while num_math_loop > 0
		
		set auto_item to item item_count of auto_mount_disk
		
		set vol_ntfs to word 1 of auto_item
		
		set dev_ntfs to word 2 of auto_item
		
		set mnt_ntfs to word 3 of auto_item
		
		if mnt_ntfs is "Yes" then
			try
				do shell script "diskutil unmount /dev/" & dev_ntfs with administrator privileges
			end try
		end if
		
		do shell script "mkdir -p /volumes/mountntfs" & vol_ntfs with administrator privileges
		
		do shell script "/usr/local/bin/ntfs-3g -o windows_names -o volname=" & vol_ntfs & " -o silent /dev/" & dev_ntfs & " /volumes/mountntfs" & vol_ntfs & "&>/dev/null &" with administrator privileges
		
		display notification "Auto mounting volumes"
		set item_count to item_count + 1
		set num_math_loop to num_math_loop - 1
	end repeat
	
end mount_auto





on mount_notauto()
	
	
	set item_count to "1" as number
	set item_count2 to "1" as number
	
	set num_math_loop to count of items in notauto_mount_disk
	set num_math_loop2 to count of items in notauto_mount_disk
	
	repeat while num_math_loop > 0
		
		
		set nice_name_root to item item_count of notauto_mount_disk
		
		set vol_ntfs to word 1 of nice_name_root
		
		set dev_ntfs to word 2 of nice_name_root
		
		set nice_name to "Disk : " & dev_ntfs & " | Name : " & vol_ntfs
		
		copy nice_name to end of nice_mount_names
		
		
		set item_count to item_count + 1
		set num_math_loop to num_math_loop - 1
	end repeat
	
	try
		set the chosen_dia_disk to (choose from list nice_mount_names with prompt "Choose the NTFS Volume to mount")
		if chosen_dia_disk is false then error number -128 -- user canceled
		copy chosen_dia_disk to end of chos_mount_dev
		
	on error
		quit
	end try
	
	set get_names to item 1 of chos_mount_dev as string
	set unix_vol to word 5 of get_names
	set unix_dev to word 2 of get_names
	
	repeat while num_math_loop2 > 0
		
		
		set nice_name_root to item item_count2 of notauto_mount_disk
		
		set ni_name to nice_name_root as string
		
		set vol_ntfs to word 1 of ni_name
		
		set dev_ntfs to word 2 of ni_name
		
		
		
		set uuid_ntfs to word 4 of ni_name
		
		if vol_ntfs = unix_vol then
			if dev_ntfs = unix_dev then
				
				set in_putstring to vol_ntfs & uuid_ntfs
				do shell script "defaults write com.SunnyNTFS.plist " & quoted form of in_putstring & " " & "false" as string
				do shell script "/usr/local/bin/ntfs-3g -o windows_names -o volname=" & unix_vol & " -o silent /dev/" & unix_dev & " /volumes/mountntfs" & unix_vol & "&>/dev/null &" with administrator privileges
			end if
		end if
		
		
		set item_count to item_count2 + 1
		set num_math_loop2 to num_math_loop2 - 1
	end repeat
	
	
	
	
	
end mount_notauto










on read_prefs()
	
	--set error_code_444 to false
	
	set item_count to "1" as number
	
	set num_math_loop to count of items in main_ntfs_dev
	
	repeat while num_math_loop > "0"
		
		set UUID_Item to item item_count of main_ntfs_uuid
		set vol_Item to item item_count of main_ntfs_vol
		set dev_Item to item item_count of main_ntfs_dev
		set mnt_Item to item item_count of main_ntfs_mnt
		
		set begin_uuid to (characters 1 thru 8 of UUID_Item) as string
		
		set share_uuid_vol to vol_Item & begin_uuid as string
		
		set plist_file to "defaults read com.SunnyNTFS.plist " as string
		
		set error_code_444 to "true"
		
		try
			set the plistfile_path to "~/Library/Preferences/com.SunnyNTFS.plist"
			
			
			
			tell application "System Events"
				set p_list to property list file (plistfile_path)
				set error_code_444 to value of property list item share_uuid_vol of p_list
			end tell
			
			if error_code_444 is "false" then
				
				copy vol_Item & " " & dev_Item & " " & mnt_Item & " " & UUID_Item to end of auto_mount_disk
				mount_auto()
			end if
			--do shell script " grep " & quoted form of shea_item & "~/Library/Preferences/com.SunnyNTFS.plist"
			
		on error
			set error_code_444 to "true"
			copy vol_Item & " " & dev_Item & " " & mnt_Item & " " & UUID_Item to end of notauto_mount_disk
			copy share_uuid_vol to end of auto_pref_dis
			
		end try
		
		
		
		set item_count to item_count + 1
		set num_math_loop to num_math_loop - 1
	end repeat
	
end read_prefs




on check_prefs()
	
	--checks the prefs file
	try
		do shell script "defaults read com.SunnyNTFS.plist PREF" as string
	on error
		do shell script "defaults write com.SunnyNTFS.plist PREF Yes"
	end try
	
end check_prefs




on make_unix_disks()
	set unix_disk_list to do shell script "diskutil list -plist | grep disk | rev | cut -c 10- | rev | awk '{print $1}' | sed 's/<string>//g'" as string
	
	set num_unix_disk_num to count paragraphs of unix_disk_list
	
	set muti_math_loop to num_unix_disk_num as number
	
	set item_num to "1"
	
	repeat while muti_math_loop > 0
		
		set fixed_disklist to paragraph item_num of unix_disk_list
		
		
		copy fixed_disklist to end of main_disk_list
		
		set item_num to item_num + 1
		set muti_math_loop to muti_math_loop - 1
		
	end repeat
	
	set itemCount to count of items in main_disk_list
	repeat with anItem from 1 to itemCount
		set firstListItem to item anItem of main_disk_list
		set occurrenceCount to 0
		repeat with anotherItem from 1 to count of items in main_disk_listfix
			set secondListItem to item anotherItem of main_disk_listfix
			if firstListItem is secondListItem then set occurrenceCount to occurrenceCount + 1
		end repeat
		if occurrenceCount = 0 then copy firstListItem to end of main_disk_listfix
	end repeat
	
end make_unix_disks












on make_ntfs_disks()
	
	set muti_math_loop to count of items in main_disk_listfix
	
	set item_num to "1"
	
	
	
	repeat while muti_math_loop > 0
		
		set dev_disk to item item_num of main_disk_listfix as string
		
		
		try
			set is_ntfs to do shell script "diskutil info " & dev_disk & " | grep -A 1 File\\ System\\ Personality | grep ntfs"
			
			copy dev_disk to end of main_ntfs_dev
			
		on error
			
		end try
		
		set item_num to item_num + 1
		set muti_math_loop to muti_math_loop - 1
	end repeat
	
end make_ntfs_disks










on make_ntfs_uuid()
	
	set muti_math_loop to count of items in main_ntfs_dev
	
	set item_num to "1"
	
	repeat while muti_math_loop > 0
		
		set dev_disk to item item_num of main_ntfs_dev as string
		
		set is_uuid to do shell script "diskutil info " & dev_disk & " | grep -A 1 \"Partition UUID\" | awk '{print $5}'"
		
		copy is_uuid to end of main_ntfs_uuid
		
		set item_num to item_num + 1
		set muti_math_loop to muti_math_loop - 1
	end repeat
	
end make_ntfs_uuid












on make_ntfs_vol()
	
	set muti_math_loop to count of items in main_ntfs_dev
	
	set item_num to "1"
	
	repeat while muti_math_loop > 0
		
		set dev_disk to item item_num of main_ntfs_dev as string
		
		set is_vol to do shell script "diskutil info " & dev_disk & " | grep \"Volume Name:\" | awk '{print $3}'"
		
		copy is_vol to end of main_ntfs_vol
		
		set item_num to item_num + 1
		set muti_math_loop to muti_math_loop - 1
	end repeat
	
end make_ntfs_vol










on make_ntfs_mnt()
	
	set muti_math_loop to count of items in main_ntfs_dev
	
	set item_num to "1"
	
	repeat while muti_math_loop > 0
		
		set dev_disk to item item_num of main_ntfs_dev as string
		
		set is_mnt to do shell script "diskutil info " & dev_disk & " | grep \"Mounted:\" | awk '{print $2}'"
		
		copy is_mnt to end of main_ntfs_mnt
		
		set item_num to item_num + 1
		set muti_math_loop to muti_math_loop - 1
	end repeat
	
end make_ntfs_mnt
