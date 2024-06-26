<#
	.SYNOPSIS
	Returns an array with the guids of the specified project files.

	.DESCRIPTION
	Gets the specified files array and returns all of their guids.

	.PARAMETER files
	An array of project files

	.EXAMPLE
	Get-Guids -files ([Sdl.ProjectAutomation.Core.ProjectFile[]] filesToGetGuids)
#>
function Get-Guids
{
	param([Sdl.ProjectAutomation.Core.ProjectFile[]] $files)
	[System.Guid[]] $guids = New-Object System.Guid[] ($files.Count);
	$i = 0;
	foreach($file in $files)
	{
		$guids.Set($i,$file.Id);
		$i++;
	}
	return $guids
}
 
Export-ModuleMember Get-Guids 

