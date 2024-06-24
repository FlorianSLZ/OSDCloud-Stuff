$Scripts2run = @(
  @{
    Name = "Installing Language Pack: DE-DE"
    Script = "Install-Language de-de"
  },
  @{
    Name = "Installing Language Pack: FR-FR"
    Script = "Install-Language fr-fr"
  },
  @{
    Name = "Installing Language Pack: IT-IT"
    Script = "Install-Language it-it"
  },
  @{
    Name = "Installing Language Pack: EN-US"
    Script = "Install-Language en-us"
  },
  @{
    Name = "Enabling built-in Windows Producy Key"
    Script = "https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/main/OOBE/Set-EmbeddedWINKey.ps1"
  },
  @{
    Name = "Windows Updates"
    Script = "https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/main/OOBE/Windows-Updates.ps1"
  },
  @{
    Name = "Saving Logs and Cleanup"
    Script = "https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/main/OOBE/OSDCloud-CleanUp.ps1"
  },
  @{
    Name = "Initiate Device Reboot"
    Script = "Restart-Computer -Force"
  }
)







Add-Type -AssemblyName PresentationFramework

# Assign messages
$MessageHeader = "Windows Preperation"
$MessageText = "Initiate Installation ..."


[XML]$xaml = @"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="IntuneWin32 Deployer" 
    Height="200" Width="420"
    WindowStartupLocation="CenterScreen" WindowStyle="None" 
    ShowInTaskbar="False" 
    ResizeMode="NoResize" Background="#FF1B1A19" Foreground="white">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="Auto" />
            <ColumnDefinition Width="*" />
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        <Grid Grid.Column="1" Margin="10">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>
            <TextBlock Name="TextMessageHeader" Text="$MessageHeader" FontSize="20" VerticalAlignment="Top" HorizontalAlignment="Left"/>
            <TextBlock Name="TextMessageBody" Text="$MessageText" Grid.Row="1" VerticalAlignment="Center" HorizontalAlignment="Left" TextWrapping="Wrap" />
        </Grid>
    </Grid>
</Window>
"@


# Load XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$Window = [Windows.Markup.XamlReader]::Load($reader)

# Create a DispatcherTimer for the "Later" button action
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromMinutes(15)
$timer.Add_Tick({
    $timer.Stop()
    $Window.Show()
}) 

$global:messageScreenText = $global:Window.FindName("TextMessageBody")

# Show the window
$Window.Show() | Out-Null

# Run the Dispatcher
#[System.Windows.Threading.Dispatcher]::Run()

$counter = 0 
$total = $Scripts2run.Count
foreach ($script in $Scripts2run) {
    $counter++
    $global:messageScreenText.Text = "$($script.Script) ($counter/$total)"
    [System.Windows.Forms.Application]::DoEvents()

    # Check if the value is a URL (starts with "http")
    if ($script.Script -match "^https?://") {
        Write-Output "($counter/$total) - Running online script: $($script.Script)"
        Start-Process PowerShell -ArgumentList "-NoL -C Invoke-WebPSScript $($script.Script)" -Wait
  } else {
    # Directly run the command (assuming it's a string)
    Write-Output "($counter/$total)- Running PowerShell command: $($script.Script)"
    Start-Process PowerShell -ArgumentList "-NoL -C $($script.Script)"  -Wait
  }
}
