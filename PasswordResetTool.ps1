# Load XML
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$xamlCode = @'

<!-- XML Code -->
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
		xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="MainWindow" Height="500" Width="400">
    <Grid Margin="0,0,0,50">
        <TextBox Name="studentNumberTextbox" HorizontalAlignment="Left" Height="23" TextWrapping="Wrap" VerticalAlignment="Top" Width="285" Margin="50,71,0,0"/>
        <Label Name="studentLabel" Content="Enter Student Number" HorizontalAlignment="Left" Margin="50,40,0,0" VerticalAlignment="Top"/>
        <Button Name="searchBtn" Content="Search" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="50,103,0,0"/>
        <Button Name="clearBtn" Content="Clear" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="130,103,0,0"/>
        <DataGrid Name="resultsDataGrid" HorizontalAlignment="Left" Height="198" VerticalAlignment="Top" Width="285" Margin="50,128,0,0" AutoGenerateColumns="False">
            <DataGrid.Columns>
                <DataGridTextColumn Binding="{Binding GivenName}" ClipboardContentBinding="{x:Null}"/>
                <DataGridTextColumn Binding="{Binding Surname}" ClipboardContentBinding="{x:Null}"/>
                <DataGridTextColumn Binding="{Binding SamAccountName}" ClipboardContentBinding="{x:Null}"/>
            </DataGrid.Columns>
        </DataGrid>
        <Button Name="resetBtn" Content="Reset" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="50,387,0,0"/>
        <TextBox Name="confirmPasswordTextbox" HorizontalAlignment="Left" Height="23" TextWrapping="Wrap" Text="Confirm Password" VerticalAlignment="Top" Width="285" Margin="50,359,0,0"/>
        <TextBox Name="passwordTextbox" HorizontalAlignment="Left" Height="23" TextWrapping="Wrap" Text="Enter Password" VerticalAlignment="Top" Width="285" Margin="50,331,0,0"/>

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

$resultsDataGrid.Columns[0].Header = "GivenName"
$resultsDataGrid.Columns[1].Header = "Surname"
$resultsDataGrid.Columns[2].Header = "SamAccountName"


$resultsDataGrid.Rows.Clear()






$searchBtn.Add_Click({
	
	$studentNumber = $studentNumberTextBox.Text + '*'

	$result = (Get-ADUser -Filter "Name -like '$studentNumber'" | Select-Object -Property GivenName, Surname, SamAccountName)
	write-host = $result


		
$resultsDataGrid.AddChild([pscustomobject]$result)
	
	

})

# Script End

# Display Script
$GUI.ShowDialog() | out-null

