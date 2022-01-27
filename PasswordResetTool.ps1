# Load XML
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$xamlCode = @'

<!-- XML Code -->
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
		xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="MainWindow" Height="550" Width="400">
    <Grid Margin="0,0,0,0">
        <TextBox Name="studentNumberTextbox" HorizontalAlignment="Left" Height="23" TextWrapping="Wrap" VerticalAlignment="Top" Width="285" Margin="50,71,0,0"/>
        <Label Name="studentLabel" Content="Enter Student Number" HorizontalAlignment="Left" Margin="50,40,0,0" VerticalAlignment="Top"/>
        <Button Name="searchBtn" Content="Search" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="50,103,0,0"/>
        <Button Name="clearBtn" Content="Clear" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="130,103,0,0"/>
        <DataGrid Name="resultsDataGrid" HorizontalAlignment="Left" Height="200" VerticalAlignment="Top" Width="285" Margin="50,128,0,0" AutoGenerateColumns="False" SelectionMode="Single" SelectedIndex="0">
            <DataGrid.Columns>
                <DataGridTextColumn Binding="{Binding GivenName}" ClipboardContentBinding="{x:Null}"/>
                <DataGridTextColumn Binding="{Binding Surname}" ClipboardContentBinding="{x:Null}"/>
                <DataGridTextColumn Binding="{Binding SamAccountName}" ClipboardContentBinding="{x:Null}"/>
            </DataGrid.Columns>
        </DataGrid>

	<Label Name="selectedStudentLabel" Content="Student Number" HorizontalAlignment="Left" Margin="50,330,0,0" VerticalAlignment="Top"/>

        <TextBox Name="passwordTextbox" HorizontalAlignment="Left" Height="23" TextWrapping="Wrap" Text="Enter Password" VerticalAlignment="Top" Width="285" Margin="50,360,0,0"/>
        <TextBox Name="confirmPasswordTextbox" HorizontalAlignment="Left" Height="23" TextWrapping="Wrap" Text="Confirm Password" VerticalAlignment="Top" Width="285" Margin="50,390,0,0"/>
        <Button Name="resetBtn" Content="Reset" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="50,420,0,0"/>

    </Grid>
</Window>
'@
#End of XML Code

# Load form
$reader = (New-Object System.Xml.XmlNodeReader $xamlCode)
$GUI = [Windows.Markup.XamlReader]::Load($reader)

# Load GUI Elements
$xamlCode.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $GUI.FindName($_.Name) }

# Script Start

# Import AD 
Import-Module activedirectory -Cmdlet Get-ADUser

# Set column header names
$resultsDataGrid.Columns[0].Header = "GivenName"
$resultsDataGrid.Columns[1].Header = "Surname"
$resultsDataGrid.Columns[2].Header = "SamAccountName"

# Search button click event
$searchBtn.Add_Click{
	# Clear any pre-existing results
	$resultsDataGrid.Items.Clear()
	
	# Assign text box value to a variable
	$studentNumber = $studentNumberTextBox.Text
	
	# Query AD to grab first name, last name and the username - assign to variable
	$result = (Get-ADUser -Filter "Name -like '$studentNumber'" | Select-Object -Property GivenName, Surname, SamAccountName)

	# print result to console
	write-host = $result

	# loop over each object from variable and add it to the datagrid
	Foreach ($results in $result) 
		{
			$resultsDataGrid.AddChild([pscustomobject]$results)
		}
}

# clear button click event
$clearBtn.Add_Click({	
	# Clears results datagrid search text box
	$resultsDataGrid.Items.Clear()
	$studentNumberTextbox.Clear()

	$passwordTextbox.Clear()
	$confirmPasswordTextbox.Clear()
	
# TODO - Clear results from everywhere including password boxes etc to return form to default state	
})


$resetBtn.Add_Click({

# Reset password logic
	# Check both password textboxes match
	if($passwordTextbox = $confirmPasswordTextbox) {
		$newPassword = $passwordTextbox.text
		
		# prints password to the console
		write-host = $newPassword

# TODO - grab selected username 
#	   - query AD using that to reset the selected user's password
#	   - dialog box to confirm password has been reset

	}
	else {
		# write error message to console
		write-host = "passwords don't match"

# TODO - dialog box to display error message
#      - clear both password boxes
	}
})



# TODO - display username as label below datagrid 
#	   - allow this to update depending on the selected row on the data grid

$value = $resultsDataGrid.SelectedItem
$username = $value.SamAccountName

$selectedStudentLabel.content = $username

# TODO - make highlighted row the same blue when focused and unfocused
#      - make password boxes not clear text, should be hidden like * or the dots
#      - column headers to correct name, eg first name, last name, username



# $newPassword = (Read-Host -Prompt "New Password" -AsSecureString)
# Set-ADAccountPassword -Identity $User -NewPassword $NewPassword -Reset

# Reseting a users password

# Grab username from selected row

#$value = $resultsDataGrid.SelectedItem
#$username = $value.SamAccountName


# Script End

# Display Script
$GUI.ShowDialog() | out-null

