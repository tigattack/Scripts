# Script to extract messages with author, timestamp, and channel from a DiscordChatExporter JSON output.
# Low effort script but it works™️
[CmdletBinding()]
param(
	[Parameter(Mandatory)]
	$InputDir,
	[Parameter(Mandatory)]
	$OutputDir,
	[int]$MaxDailyMessages
)

Set-StrictMode -Version Latest

# Start timer
$stopwatchTotal =  [system.diagnostics.stopwatch]::StartNew()

# Get all input files
Write-Output 'Getting all JSON input files...'
$inputFiles = Get-ChildItem -Path $InputDir -Recurse -File | Where-Object { $_.Extension -eq '.json' }

# Count the number of files
If (Get-Member -InputObject $inputFiles -Name 'Count') {
	$inputFilesCount = $inputFiles.Count
}
Else {
	$inputFilesCount = 1
}

Write-Output "Found $inputFilesCount input files."

$convertedFiles = 0
$convertedMsgsTotal = 0

foreach ($file in $inputFiles) {

	# Start file timer
	$stopwatchFile =  [system.diagnostics.stopwatch]::StartNew()

	# Calculate and write progress output
	$pctCompleteFiles = $convertedFiles/$inputFilesCount*100
	$progressFiles = @{
		Activity		= 'Converting files'
		PercentComplete	= $pctCompleteFiles
		Status			= "Parsed $convertedFiles files; $([Math]::Floor($pctCompleteFiles))% complete"
		Id				= 0
	}
	Write-Progress @progressFiles

	$output			= @()
	$convertedMsgs	= 0
	$dailyMsgs		= 0
	$skippedMsgs	= 0

	# Get input file contents and convert to object
	Write-Output "`nParsing $($file.BaseName)..."
	$inputContent = $file | Get-Content -Raw | ConvertFrom-Json

	$dateStamp = ($inputContent.messages | Sort-Object -Property 'timestamp')[0].timestamp

	# Create output file
	$outFile = Join-Path -Path $OutputDir -ChildPath $file.Name.Replace('json','txt')
	New-Item -Path $outFile -Type File -Force | Out-Null

	foreach ($message in $inputContent.messages) {

		# Calculate and write progress output
		$pctCompleteMsgs = $convertedMsgs/$inputContent.messageCount*100
		$progressMsgs = @{
			Activity		= 'Converting messages'
			PercentComplete	= $pctCompleteMsgs
			Status			= "Converted $convertedMsgs messages; $([Math]::Floor($pctCompleteMsgs))% complete"
			Id				= 1
			ParentId		= 0
		}
		Write-Progress @progressMsgs

		If ($MaxDailyMessages) {

			# Set new datestamp if it's a new day
			If ($dateStamp.Date -lt $message.timestamp.Date) {
				$dateStamp	= $message.timestamp
				$dailyMsgs	= 0
			}

			# Write message to output file and increment daily message count
			If ($dailyMsgs -lt $MaxDailyMessages) {
				$output += '{0}|{1}|A|{2}' -f `
					([DateTimeOffset]$message.timestamp).ToUnixTimeSeconds(),
					$message.author.name,
					"$($inputContent.channel.name)/$($message.id)"
				$convertedMsgs++
				$dailyMsgs++
			}

			# Skip if we've hit the daily message limit
			Else {
				Write-Verbose "Skipping message $($skippedMsgs+1) due to daily message limit."
				$skippedMsgs++
				continue
			}
		}

		# Write message to output file
		Else {
			$output += '{0}|{1}|A|{2}' -f `
				([DateTimeOffset]$message.timestamp).ToUnixTimeSeconds(),
				$message.author.name,
				"$($inputContent.channel.name)/$($message.id)"
			$convertedMsgs++
		}

	}

	# Complete messages progress
	Write-Progress -Activity "Converted messages from $($file.BaseName)" -Id 1 -Completed

	# Stop stopwatch
	$stopwatchFile.Stop()

	# Write output to file
	Write-Output "Writing output to $($outFile)..."
	Set-Content -Path $outFile -Value $output

	$convertedFiles++
	$convertedMsgsTotal += $convertedMsgs

	# Calculate conversion rate
	$msgsPerSecondFile = [Math]::Round(
		($convertedMsgs/($stopwatchFile.ElapsedMilliseconds/1000)),0
	)

	If ($skippedMsgs -gt 0) {
		Write-Output "Completed $($file.BaseName) in $($stopwatchFile.Elapsed.TotalSeconds) seconds. Converted $($convertedMsgs) messages at ~$($msgsPerSecondFile) messages/second. Skipped $($skippedMsgs) messages due to daily message limit."
	}
	Else {
		Write-Output "Completed $($file.BaseName) in $($stopwatchFile.Elapsed.TotalSeconds) seconds. Converted $($convertedMsgs) messages at ~$($msgsPerSecondFile) messages/second."
	}
}

# Complete files progress
Write-Progress -Activity "Converted files from $InputDir" -Id 0 -Completed

# Get all output files
Write-Output "`nGetting all output files..."
$outputFiles = Get-ChildItem -Path $OutputDir -Exclude 'messages.txt'

# Count the number of files
If (Get-Member -InputObject $outputFiles -Name 'Count') {
	$outputFilesCount = $outputFiles.Count
}
Else {
	$outputFilesCount = 1
}

Write-Output "Found $outputFilesCount output files."

# Create output file
$outputFile = New-Item -Path (Join-Path -Path $outputDir -ChildPath messages.txt) -Type File -Force

$combinedFiles = 0

foreach ($file in $outputFiles) {

	# Calculate and write progress output
	$pctCompleteFileCombine = $combinedFiles/$outputFilesCount*100
	$progressFiles = @{
		Activity		= 'Combining files'
		PercentComplete	= $pctCompleteFileCombine
		Status			= "Combined $combinedFiles files; $([Math]::Floor($pctCompleteFileCombine))% complete"
		Id				= 0
	}
	Write-Progress @progressFiles

	# Combine files
	Write-Output "Merging $($file.Name) into $($outputFile.Name)..."
	Add-Content -Path $outputFile -Value ($file | Get-Content)

	# Remove file
	Write-Output "Removing $($file.Name)..."
	$file | Remove-Item -Force
}

# Sort output file and trim new line from beginning of file
Write-Output "`nSorting output file..."
($outputFile | Get-Content -Raw).Split("`n") | Sort-Object | Select-Object -Skip 1 | Set-Content -Path $outputFile.FullName -Force

# Complete files progress
Write-Progress -Activity "Combined output files" -Id 0 -Completed

# Stop timer
$stopwatchTotal.Stop()
$msgsPerSecondTotal = [Math]::Round(
	($convertedMsgsTotal/($stopwatchTotal.ElapsedMilliseconds/1000)),0
)

Write-Output @"

Completed conversion.

Converted $($convertedMsgsTotal) messages from $($inputFilesCount) files.
Elapsed time: $([Math]::Round($stopwatchTotal.ElapsedMilliseconds/1000,0)) seconds.
Average processing rate: $($msgsPerSecondTotal) messages/second.
Output file: $($outputFile)
Output file size: $([Math]::Floor((Get-Item $outputFile).Length/1MB)) MB
"@
