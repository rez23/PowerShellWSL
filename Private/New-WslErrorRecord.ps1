function New-WslErrorRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [hashtable]$InputObject
    )

    $stdErrText = ""
    if ($InputObject.ContainsKey('StdErr') -and $null -ne $InputObject['StdErr']) {
        $stdErrText = ([string]$InputObject['StdErr']).Trim()
    }
    elseif ($InputObject.ContainsKey('Stderr') -and $null -ne $InputObject['Stderr']) {
        $stdErrText = ([string]$InputObject['Stderr']).Trim()
    }

    $messageText = ""
    if ($InputObject.ContainsKey('Message') -and $null -ne $InputObject['Message']) {
        $messageText = ([string]$InputObject['Message']).Trim()
    }

    if ([string]::IsNullOrWhiteSpace($stdErrText) -and [string]::IsNullOrWhiteSpace($messageText)) {
        throw [System.ArgumentException]::new("InputObject must include a non-empty 'Message' or 'StdErr' field.", "InputObject")
    }

    $knownKeys = @('Message', 'ErrorId', 'Category', 'TargetObject', 'InnerException', 'Data', 'ExceptionType')

    $message = if (-not [string]::IsNullOrWhiteSpace($stdErrText)) { $stdErrText } else { $messageText }
    $errorId = if ($InputObject.ContainsKey('ErrorId') -and -not [string]::IsNullOrWhiteSpace([string]$InputObject['ErrorId'])) {
        [string]$InputObject['ErrorId']
    } else {
        'PowerShellWSL.OperationFailed'
    }

    $category = [System.Management.Automation.ErrorCategory]::NotSpecified
    if ($InputObject.ContainsKey('Category') -and $null -ne $InputObject['Category']) {
        if ($InputObject['Category'] -is [System.Management.Automation.ErrorCategory]) {
            $category = $InputObject['Category']
        } else {
            $category = [System.Management.Automation.ErrorCategory]::Parse([System.Management.Automation.ErrorCategory], [string]$InputObject['Category'], $true)
        }
    }

    $targetObject = if ($InputObject.ContainsKey('TargetObject')) { $InputObject['TargetObject'] } else { $null }
    $innerException = if ($InputObject.ContainsKey('InnerException')) { $InputObject['InnerException'] } else { $null }

    $exceptionType = [System.InvalidOperationException]
    if ($InputObject.ContainsKey('ExceptionType') -and $InputObject['ExceptionType'] -is [type]) {
        $exceptionType = $InputObject['ExceptionType']
    }

    $exception = if ($innerException -is [System.Exception]) {
        [System.Activator]::CreateInstance($exceptionType, @($message, $innerException))
    } else {
        [System.Activator]::CreateInstance($exceptionType, @($message))
    }

    if ($InputObject.ContainsKey('Data') -and $InputObject['Data'] -is [hashtable]) {
        foreach ($entry in $InputObject['Data'].GetEnumerator()) {
            $exception.Data[$entry.Key] = $entry.Value
        }
    }

    foreach ($entry in $InputObject.GetEnumerator()) {
        if ($knownKeys -contains $entry.Key) {
            continue
        }

        $exception.Data[$entry.Key] = $entry.Value
    }

    [System.Management.Automation.ErrorRecord]::new(
        $exception,
        $errorId,
        $category,
        $targetObject
    )
}
