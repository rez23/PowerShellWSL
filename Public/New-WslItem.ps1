function New-WslItem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter({
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

                Get-WslDistribution -Distribution "$wordToComplete*" | ForEach-Object { $_.Distribution }
            })]
        [string]$Distribution,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ArgumentCompleter({
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

                $DistributionName = $fakeBoundParameters['Distribution']
                if (-not $DistributionName) {
                    $DistributionName = Get-WslDistribution -Default | Select-Object -ExpandProperty Distribution
                }

                Get-ChildItem -Path "\\wsl.localhost\${DistributionName}${wordToComplete}*" -ErrorAction SilentlyContinue | 
                ForEach-Object { $_.FullName -replace "\\\\wsl(?:\.[^\\]+)?\.localhost\\$DistributionName", "" } })]
        [string[]]$Path,

        # New-Item params
        [Parameter(ParameterSetName = 'nameSet', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        ${Name},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('Type')]
        [string]
        ${ItemType},

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Target')]
        [System.Object]
        ${Value},

        [switch]
        ${Force},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential})


    dynamicparam {
        # Get the dynamic parameters from the New-Item cmdlet
        try {
            $targetCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\New-Item', [System.Management.Automation.CommandTypes]::Cmdlet, $PSBoundParameters)
            $dynamicParams = @($targetCmd.Parameters.GetEnumerator() | Microsoft.PowerShell.Core\Where-Object { $_.Value.IsDynamic })
            if ($dynamicParams.Length -gt 0) {
                $paramDictionary = [Management.Automation.RuntimeDefinedParameterDictionary]::new()
                foreach ($param in $dynamicParams) {
                    $param = $param.Value

                    if (-not $MyInvocation.MyCommand.Parameters.ContainsKey($param.Name)) {
                        $dynParam = [Management.Automation.RuntimeDefinedParameter]::new($param.Name, $param.ParameterType, $param.Attributes)
                        $paramDictionary.Add($param.Name, $dynParam)
                    }
                }
                return $paramDictionary
            }
        }
        catch {
            throw
        }
    }
    process {
        if (-not $Distribution) {
            Write-Verbose "No distribution name specified. Using the default WSL distribution."
            $WslDefaultDistro = Get-WslDistribution -Default -ErrorAction Stop
            $Distribution = $WslDefaultDistro.Distribution
        }
    
        $OtherParameters = @{} + $PSBoundParameters
        [void]$OtherParameters.Remove('ErrorAction')
        [void]$OtherParameters.Remove('Distribution')
        [void]$OtherParameters.Remove('Path')

        Microsoft.PowerShell.Management\New-Item -Path ($Path | ForEach-Object {"\\wsl.localhost\$Distribution$_"}) @OtherParameters -ErrorAction Stop
    }
}
<#

.ForwardHelpTargetName Microsoft.PowerShell.Management\New-Item
.ForwardHelpCategory Cmdlet

#>