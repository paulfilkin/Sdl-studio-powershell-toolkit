<#
	.SYNOPSIS
	Creates a new package based on an existing filebased project.

	.DESCRIPTION
	Creates a package from the given filebased project based upon the provided target language.

	.PARAMETER language
	Represents the target language from the project to be used for creating the package.

	.PARAMETER packagePath
	Represents the location where the package should be saved at.

	.PARAMETER projectToProcess
	The Existing filebased project to create the package from.

	.EXAMPLE
	New-Package -language ([Sdl.Core.Globalization.Language] targetLanguage) -packagePath ("C\Path\To\Package\test.sdlppx")
		-projectToProcess ([Sdl.ProjectAutomation.FileBased.FileBasedProject] project to get the package from)
#>
function New-Package
{
	param(
	[Sdl.Core.Globalization.Language] $language,
	[String] $packagePath,
	[Sdl.ProjectAutomation.FileBased.FileBasedProject]$projectToProcess)
	
	$today = Get-Date;
	[Sdl.ProjectAutomation.Core.TaskFileInfo[]] $taskFiles =  Get-TaskFileInfoFiles $language $projectToProcess;
	[Sdl.ProjectAutomation.Core.ManualTask] $task = $projectToProcess.CreateManualTask("Translate", "API translator", $today +1 ,$taskFiles);
	[Sdl.ProjectAutomation.Core.ProjectPackageCreationOptions] $packageOptions = Get-PackageOptions
	[Sdl.ProjectAutomation.Core.ProjectPackageCreation] $package = $projectToProcess.CreateProjectPackage($task.Id, "mypackage",
                "A package created by the API", $packageOptions, ${function:Write-PackageProgress}, ${function:Write-PackageMessage}); # Status - Failed -> Repair from here..
	$projectToProcess.SavePackageAs($package.PackageId, $packagePath);
}

function Get-PackageOptions
{
	[Sdl.ProjectAutomation.Core.ProjectPackageCreationOptions] $packageOptions = New-Object Sdl.ProjectAutomation.Core.ProjectPackageCreationOptions;
	$packageOptions.IncludeAutoSuggestDictionaries = $false;
	$packageOptions.IncludeMainTranslationMemories = $false;
    $packageOptions.IncludeTermbases = $false;
    $packageOptions.ProjectTranslationMemoryOptions = [Sdl.ProjectAutomation.Core.ProjectTranslationMemoryPackageOptions]::UseExisting;
    $packageOptions.RecomputeAnalysisStatistics = $false;
    $packageOptions.RemoveAutomatedTranslationProviders = $true;
    return $packageOptions;
}

function Write-PackageProgress {
	param(
	$Caller,
	$ProgressEventArgs
	)

	$Message = $ProgressEventArgs.StatusMessage

	if ($null -ne $Message -and $Message -ne "") {
		$Percent = $ProgressEventArgs.PercentComplete
		if ($Percent -eq 100) {
			$Message = "Completed"
		}

		# write textual progress percentage in console
		if ($host.name -eq 'ConsoleHost') {
			Write-Host "$($Percent.ToString().PadLeft(5))%	$Message"
			Start-Sleep -Seconds 1
		}
		# use PowerShell progress bar in PowerShell environment since it does not support writing on the same line using `r
		else {
			Write-Progress -Activity "Processing task" -PercentComplete $Percent -Status $Message
			# when all is done, remove the progress bar
			if ($Percent -eq 100 -and $Message -eq "Completed") {
				Write-Progress -Activity "Processing task" -Completed
			}
		}
	}
}

function Write-PackageMessage {
	param(
	$Caller,
	$MessageEventArgs
	)

	$Message = $MessageEventArgs.Message

	if ($Message.Source -ne "Package import") {
		Write-Host "$($Message.Source)" -ForegroundColor DarkYellow
	}
	Write-Host "$($Message.Level): $($Message.Message)" -ForegroundColor Magenta
	if ($Message.Exception) {
		Write-Host "$($Message.Exception)" -ForegroundColor Magenta
	}
}

Export-ModuleMember New-Package;