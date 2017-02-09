(*
    Delfim Machado - dbcm@profundos.org
    XPTO:: Portuguese OpenSource Community
*)

-- Archive POP mails to IMAP account?
property ArchivePOP2IMAP : true

-- What is the name of the IMAP Account to move POP mails?
property MainIMAPAccount : "Profundos"

-- Do log?
property DoLog : true

on run {input, parameters}
	
	using terms from application "Mail"
		
		my logThis("---------- Mail.app Archiver starting")
		
		tell application "Mail"
			set selectedMails to the selection
			set nCount to count of selection
			
			my logThis("Starting loop...")
			repeat with eachMessage in selectedMails
				my logThis("repeat, msg: " & subject of eachMessage)
				
				-- generic info about the message
				set msgDate to date received of eachMessage
				set msgMonth to month of msgDate as integer
				set msgYear to year of msgDate as integer
				
				-- message endpoint
				set mboxName to "Archive/" & msgYear & "/" & msgYear & "-" & msgMonth
				
				try
					set msgAccount to name of account of mailbox of eachMessage as string
					set msgAccountType to account type of account of mailbox of eachMessage
				on error errText
					-- no account, lets move them to IMAP
					set msgAccountType to "local"
				end try
				
				my logThis("accountType " & msgAccountType)
				
				if msgAccountType is imap or msgAccountType is iCloud then
					-- mails alive in a IMAP account
					tell account msgAccount
						my logThis("with account: " & msgAccount)
						try
							set mbox to mailbox named mboxName
							get name of mbox
						on error
							make new mailbox with properties {name:mboxName}
							set mbox to mailbox named mboxName
						end try
						try
							move eachMessage to mbox
						on error errText number errNum
							my logThis("Err: " & errNum & " . " & errText)
						end try
					end tell
				else
					-- mails sent and received from a pop account
					try
						my logThis("mail is on pop or local")
						if ArchivePOP2IMAP then -- Archive POP or LOCAL mails to IMAP account
							my logThis("ArchivePOP2IMAP is active")
							
							tell account MainIMAPAccount
								if the mailbox mboxName exists then
								else
									make new mailbox with properties {name:mboxName}
								end if
								set mbox to mailbox named mboxName
							end tell
							move eachMessage to mbox
						end if
					on error myErr
						display dialog "Something gone mad (" & myErr & ")" buttons "OK"
					end try
					(*
				else
					my logThis("Account type: " & (msgAccountType as string) & " _ " & subject of eachMessage)
*)
				end if
				
			end repeat
			
		end tell
		
	end using terms from
	
	return input
end run



on logThis(str)
	if DoLog then -- only log if this is true (WOW)
		set LogFile to a reference to (path to desktop as string) & "Mail.app Archiver.log"
		set tStamp to current date
		set myNow to ((year of tStamp as string) & (month of tStamp as string) & (day of tStamp as string))
		try
			open for access file LogFile with write permission
			-- set eof of file logFile to 0
			write myNow & " : " & str & return to file LogFile starting at eof
			close access file LogFile
			log str
			
		on error errText number errNum
			close access file LogFile
			--display dialog logThiserrText
		end try
	end if
end logThis