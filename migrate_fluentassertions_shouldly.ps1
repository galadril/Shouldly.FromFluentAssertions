param(
    # The Path to the solution file to migrate
    [Parameter(Mandatory = $true)]
    [Alias("s")]
    [ValidateScript({ 
            if (! (Test-Path $_ -PathType Leaf)) {
                throw "Solution path '$_' does not exist or is not a file."
            }
            if (! $_.ToString().EndsWith(".sln")) {
                throw "Solution path '$_' is not a .sln file."
            }
            return $true
        })]
    [System.IO.FileInfo]$SolutionPath
)

# Define a direct mapping between FluentAssertions and Shouldly
$mapping = @(
    @{ Key = 'using FluentAssertions;' ; Value = 'using Shouldly;' },
    @{ Key = 'using FluentAssertions.Execution;' ; Value = 'using Shouldly;' },
    @{ Key = 'Should().Be(' ; Value = 'ShouldBe(' },
    @{ Key = 'Should().NotBe(' ; Value = 'ShouldNotBe(' },
    @{ Key = 'Should().BeNull(' ; Value = 'ShouldBeNull(' },
    @{ Key = 'Should().NotBeNull(' ; Value = 'ShouldNotBeNull(' },
    @{ Key = 'Should().BeTrue(' ; Value = 'ShouldBeTrue(' },
    @{ Key = 'Should().BeEquivalentTo' ; Value = 'ShouldBe' },
    @{ Key = 'Should().BeFalse(' ; Value = 'ShouldBeFalse(' },
    @{ Key = 'Should().BeSameAs(' ; Value = 'ShouldBeSameAs(' },
    @{ Key = 'Should().NotBeSameAs(' ; Value = 'ShouldNotBeSameAs(' },
    @{ Key = 'Should().BeOfType(' ; Value = 'ShouldBeOfType(' },
    @{ Key = 'Should().NotBeOfType(' ; Value = 'ShouldNotBeOfType(' },
    @{ Key = 'Should().BeGreaterThan(' ; Value = 'ShouldBeGreaterThan(' },
    @{ Key = 'Should().BeGreaterThanOrEqualTo(' ; Value = 'ShouldBeGreaterThanOrEqualTo(' },
    @{ Key = 'Should().BeLessThan(' ; Value = 'ShouldBeLessThan(' },
    @{ Key = 'Should().BeLessThanOrEqualTo(' ; Value = 'ShouldBeLessThanOrEqualTo(' },
    @{ Key = 'Should().BePositive(' ; Value = 'ShouldBePositive(' },
    @{ Key = 'Should().BeNegative(' ; Value = 'ShouldBeNegative(' },
    @{ Key = 'Should().BeInRange(' ; Value = 'ShouldBeInRange(' },
    @{ Key = 'Should().NotBeInRange(' ; Value = 'ShouldNotBeInRange(' },
    @{ Key = 'Should().Contain(' ; Value = 'ShouldContain(' },
    @{ Key = 'Should().NotContain(' ; Value = 'ShouldNotContain(' },
    @{ Key = 'Should().BeEmpty(' ; Value = 'ShouldBeEmpty(' },
    @{ Key = 'Should().NotBeEmpty(' ; Value = 'ShouldNotBeEmpty(' },
    @{ Key = 'Should().HaveCount(' ; Value = 'Count.ShouldBe(' },
    @{ Key = 'Should().HaveCountGreaterThan(' ; Value = 'Count.ShouldBeGreaterThan(' },
    @{ Key = 'Should().HaveCountLessThan(' ; Value = 'Count.ShouldBeLessThan(' },
    @{ Key = 'Should().AllBeAssignableTo(' ; Value = 'ShouldAllBeAssignableTo(' },
    @{ Key = 'Should().OnlyHaveUniqueItems(' ; Value = 'ShouldAllBeUnique(' },
    @{ Key = 'Should().ContainKey(' ; Value = 'ShouldContainKey(' },
    @{ Key = 'Should().NotContainKey(' ; Value = 'ShouldNotContainKey(' },
    @{ Key = 'Should().ContainValue(' ; Value = 'ShouldContainValue(' },
    @{ Key = 'Should().NotContainValue(' ; Value = 'ShouldNotContainValue(' },
    @{ Key = 'Should().Throw(' ; Value = 'ShouldThrow(' },
    @{ Key = 'Should().NotThrow(' ; Value = 'ShouldNotThrow(' },
    @{ Key = 'Should().NotThrowAsync(' ; Value = 'ShouldNotThrowAsync(' },
    @{ Key = 'Should().ThrowExactly(' ; Value = 'ShouldThrowExactly(' },
    @{ Key = 'Should().Throw().WithMessage(' ; Value = 'ShouldThrow().Message.ShouldBe(' },
    @{ Key = 'Should().BeOfType<' ; Value = 'ShouldBeOfType<' },
    @{ Key = 'Should().ThrowAsync<' ; Value = 'ShouldThrowAsync<' },
    @{ Key = 'Should().Throw' ; Value = 'ShouldThrow' },
    @{ Key = 'Should().NotEqual' ; Value = 'ShouldNotBe' },
    @{ Key = 'ShouldThrowExactly' ; Value = 'ShouldThrow' },
    @{ Key = 'Should().BeAssignableTo' ; Value = 'ShouldBeAssignableTo' },
    @{ Key = 'Should().NotBeNullOrEmpty' ; Value = 'ShouldNotBeNullOrEmpty' },
    @{ Key = 'Should().NotBeEmpty' ; Value = 'ShouldNotBeEmpty' },
    @{ Key = 'Should().NotBeNull' ; Value = 'ShouldNotBeNull' },
    @{ Key = 'Should().NotBeNullOrWhiteSpace' ; Value = 'ShouldNotBeNullOrWhiteSpace' },
    @{ Key = 'Should().MatchRegex' ; Value = 'ShouldMatch' },
    @{ Key = 'Should().BeNull' ; Value = 'ShouldBeNull' },
    @{ Key = 'Should().OnlyContain('; Value = 'ShouldAllBe('},
    @{ Key = 'Should().BeGreaterOrEqualTo('; Value = 'ShouldBeGreaterThanOrEqualTo('},
    
    # String assertions
    @{ Key = 'Should().StartWith(' ; Value = 'ShouldStartWith(' },
    @{ Key = 'Should().EndWith(' ; Value = 'ShouldEndWith(' },
    @{ Key = 'Should().HaveLength(' ; Value = 'Length.ShouldBe(' },
    @{ Key = 'Should().BeEmpty(' ; Value = 'ShouldBeEmpty(' },
    @{ Key = 'Should().BeNullOrEmpty(' ; Value = 'ShouldBeNullOrEmpty(' },
    @{ Key = 'Should().BeNullOrWhiteSpace(' ; Value = 'ShouldBeNullOrWhiteSpace(' },
    
    # Collection assertions
    @{ Key = 'Should().BeSubsetOf(' ; Value = 'ShouldBeSubsetOf(' },
    @{ Key = 'Should().HaveSameCount(' ; Value = 'Count.ShouldBe(' },
    @{ Key = 'Should().AllBe(' ; Value = 'ShouldAllBe(' },
    @{ Key = 'Should().Contain().Which.' ; Value = 'ShouldContain(item => item.' },
    @{ Key = 'Should().ContainSingle(' ; Value = 'ShouldContainSingle(' },
    
    # Dictionary assertions
    @{ Key = 'Should().ContainKeyAndValue(' ; Value = 'ShouldContainKeyAndValue(' },
    
    # DateTime assertions
    @{ Key = 'Should().BeAfter(' ; Value = 'ShouldBeGreaterThan(' },
    @{ Key = 'Should().BeBefore(' ; Value = 'ShouldBeLessThan(' },
    @{ Key = 'Should().BeOnOrAfter(' ; Value = 'ShouldBeGreaterThanOrEqualTo(' },
    @{ Key = 'Should().BeOnOrBefore(' ; Value = 'ShouldBeLessThanOrEqualTo(' },
    
    # Tasks/async
    @{ Key = 'Should().CompleteWithin(' ; Value = 'ShouldCompleteIn(' },
    
    # Additional common patterns
    @{ Key = 'Should().Equal(' ; Value = 'ShouldBe(' },
    @{ Key = 'Should().BeOneOf(' ; Value = 'ShouldBeOneOf(' }
    
    # Commented mappings for methods without direct equivalents
    # @{ Key = 'Should().BeInAscendingOrder(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().BeInDescendingOrder(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().Intersect(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().ContainInOrder(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().ContainInConsecutiveOrder(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().BeCloseTo(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().BeSameDateAs(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().HaveDay(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().HaveMonth(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().HaveYear(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().HaveHour(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().HaveMinute(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().HaveSecond(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().Exist(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().NotExist(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().NotCompleteWithin(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().BeApproximately(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().SatisfyRespectively(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().SatisfyAllConditions(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().Match(' ; Value = '/* No direct equivalent in Shouldly */' },
    # @{ Key = 'Should().ContainItemsAssignableTo<' ; Value = '/* No direct equivalent in Shouldly */' }
)

# Function to get the encoding of a file
function Get-FileEncoding {
    param (
        [string]$filePath
    )
    $stream = [System.IO.File]::OpenRead($filePath)
    $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::Default, $true)
    $reader.Read() | Out-Null
    $encoding = $reader.CurrentEncoding
    $reader.Close()
    return $encoding
}

# Function to remove AssertionScope and keep internal lines
function Convert-AssertionScope-Block {
    param (
        [string]$content
    )
    $pattern = 'using \(new AssertionScope\(\)\)\s*{([^}]*)}'
    
    return [regex]::Replace($content, $pattern, { param($m) $m.Groups[1].Value.Trim() })
}

function Remove-AssertionScope-Implicit {
    param (
        [string]$content
    )
    $pattern = '\t*using var \w+\s*=\s*new AssertionScope\(\);(\r?\n?)*'
    
    return [regex]::Replace($content, $pattern, '')
}

# Function to remove duplicate using statements at the top of the file
function Remove-DuplicateUsings {
    param (
        [string]$content
    )
    $lines = $content -split "`n"
    $uniqueUsings = @{ }
    $result = @()
    $inUsingsSection = $true

    foreach ($line in $lines) {
        if ($inUsingsSection -and $line.Trim().StartsWith("using ")) {
            if (-not $uniqueUsings.ContainsKey($line.Trim())) {
                $uniqueUsings[$line.Trim()] = $true
                $result += $line
            }
        }
        else {
            $inUsingsSection = $false
            $result += $line
        }
    }

    return $result -join "`n"
}

# Function to replace WithMessage in ShouldThrow and ShouldThrowAsync
function Convert-WithMessage {
    param (
        [string]$content
    )
    $patterns = @(
        @{ Pattern = 'await\s+(\w+)\.ShouldThrowAsync<([^>]+)>\(\)\s*\.\s*WithMessage\("([^"]+)"\)' ; Replacement = 'var ex = await $1.ShouldThrowAsync<$2>(); ex.Message.ShouldBe("$3");' },
        @{ Pattern = '(\w+)\.ShouldThrow<([^>]+)>\(\)\s*\.\s*WithMessage\("([^"]+)"\)' ; Replacement = 'var ex = await $1.ShouldThrow<$2>(); ex.Message.ShouldBe("$3");' },
        @{ Pattern = '(\w+)\.ShouldThrow<([^>]+)>\(\)\s*\.\s*WithMessage\(\$"([^"]+)"\)' ; Replacement = 'var ex = await $1.ShouldThrow<$2>(); ex.Message.ShouldBe("$3");' },
        @{ Pattern = 'await\s+(\w+)\.ShouldThrowAsync<([^>]+)>\(\)' ; Replacement = 'var ex = await $1.ShouldThrowAsync<$2>();' },
        @{ Pattern = '(\w+)\.ShouldThrow<([^>]+)>\(\)' ; Replacement = '$1.ShouldThrow<$2>()' }
    )

    foreach ($pattern in $patterns) {
        $content = [regex]::Replace($content, $pattern.Pattern, $pattern.Replacement)
    }

    return $content
}

function Convert-ContainSingleWhichMessage {
    param (
        [string]$content
    )

    $patterns = @(
        # Match for the exception message check pattern
        @{ Pattern = '(\w+)\.Should\(\)\s*\.\s*ContainSingle\(\)\s*\.\s*Which\s*\.\s*Exception\s*\.\s*Message\s*\.\s*ShouldBe\("([^"]+)"\)' ; Replacement = '$1.ShouldContain(item => item.Exception.Message.Equals("$2"))' },

        # Match for the message template text check pattern
        @{ Pattern = '(\w+)\.Should\(\)\s*\.\s*ContainSingle\(\)\s*\.\s*Which\s*\.\s*MessageTemplate\s*\.\s*Text\s*\.\s*ShouldBe\("([^"]+)"\)' ; Replacement = '$1.ShouldContain(item => item.MessageTemplate.Text.Equals("$2"))' },

        # Generic version to account for chained method calls
        @{ Pattern = '(\w+)\.Should\(\)\s*\.\s*ContainSingle\(\)\s*\.\s*Which\s*\.\s*MessageTemplate\s*\.\s*Text\s*\.\s*ShouldBe\("([^"]+)"\)' ; Replacement = '$1.ShouldContain(item => item.MessageTemplate.Text.Equals("$2"))' }
    )

    foreach ($pattern in $patterns) {
        $content = [regex]::Replace($content, $pattern.Pattern, $pattern.Replacement)
    }

    return $content
}

# Get all C# files in the solution
$files = Get-ChildItem -Path $SolutionPath.Directory -Recurse -Include *.cs

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    if ($null -eq $content) {
        Write-Host "⚠️ Skipping file (content is null): $($file.FullName)"
        continue
    }
    $encoding = Get-FileEncoding -filePath $file.FullName
    $originalContent = $content

    # Perform direct replacements for FluentAssertions to Shouldly
    foreach ($map in $mapping) {
        $content = $content.Replace($map.Key, $map.Value)
    }

    # Replace AssertionScope blocks while retaining internal lines
    $content = Convert-AssertionScope-Block -content $content

    # Remove implicit AssertionScope declarations and trim whitespace
    $content = Remove-AssertionScope-Implicit -content $content
    
    # Replace WithMessage in ShouldThrowAsync
    $content = Convert-WithMessage -content $content

    # Replace ContainSingle().Which.Exception.Message.ShouldBe
    $content = Convert-ContainSingleWhichMessage -content $content

    # Remove duplicate using statements
    $content = Remove-DuplicateUsings -content $content

    # Save the updated content back to the file with the original encoding if it has changed
    if ($content -ne $originalContent) {
        Write-Host "✅ Updated file: $($file.FullName)"
        [System.IO.File]::WriteAllText($file.FullName, $content, $encoding)
    }
}

# Check for central package management file
$centralPackageFile = Get-ChildItem -Path $SolutionPath.Directory -Recurse -Include "Directory.Packages.props"

if ($centralPackageFile) {
    $centralContent = Get-Content -Path $centralPackageFile.FullName -Raw
    $centralEncoding = Get-FileEncoding -filePath $centralPackageFile.FullName
    $originalCentralContent = $centralContent

    # Remove FluentAssertions package and add Shouldly package in the same place
    $centralContent = $centralContent -replace '<PackageVersion Include="FluentAssertions".*?\/>', '<PackageVersion Include="Shouldly" Version="4.3.0" />'

    # Save updated central package file with the original encoding if it has changed
    if ($centralContent -ne $originalCentralContent) {
        Write-Host "✅ Updated central package management file: $($centralPackageFile.FullName)"
        [System.IO.File]::WriteAllText($centralPackageFile.FullName, $centralContent, $centralEncoding)
    }

    # Adjust individual project files if central package management is not used
    $projectFiles = Get-ChildItem -Path $SolutionPath.Directory -Recurse -Include *.csproj
    foreach ($project in $projectFiles) {
        $projectContent = Get-Content -Path $project.FullName -Raw
        $projectEncoding = Get-FileEncoding -filePath $project.FullName
        $originalProjectContent = $projectContent

        # Remove FluentAssertions package and add Shouldly package in the same place
        $projectContent = $projectContent -replace '<PackageReference Include="FluentAssertions".*?\/>', '<PackageReference Include="Shouldly" />'
        $projectContent = $projectContent -replace '<PackageReference Include="FluentAssertions" \/>', '<PackageReference Include="Shouldly" />'

        # Save updated project file with the original encoding if it has changed
        if ($projectContent -ne $originalProjectContent) {
            Write-Host "✅ Updated project file: $($project.FullName)"
            [System.IO.File]::WriteAllText($project.FullName, $projectContent, $projectEncoding)
        }
    }
}
else {
    # Adjust individual project files if central package management is not used
    $projectFiles = Get-ChildItem -Path $SolutionPath.Directory -Recurse -Include *.csproj

    foreach ($project in $projectFiles) {
        $projectContent = Get-Content -Path $project.FullName -Raw
        $projectEncoding = Get-FileEncoding -filePath $project.FullName
        $originalProjectContent = $projectContent

        # Remove FluentAssertions package and add Shouldly package in the same place
        $projectContent = $projectContent -replace '<PackageReference Include="FluentAssertions".*?\/>', '<PackageReference Include="Shouldly" Version="4.3.0" />'
        $projectContent = $projectContent -replace '<PackageReference Include="FluentAssertions" \/>', '<PackageReference Include="Shouldly" Version="4.3.0" />'
        $projectContent = $projectContent -replace '<PackageVersion Include="FluentAssertions".*?\/>', '<PackageVersion Include="Shouldly" Version="4.3.0" />'

        # Save updated project file with the original encoding if it has changed
        if ($projectContent -ne $originalProjectContent) {
            Write-Host "✅ Updated project file: $($project.FullName)"
            [System.IO.File]::WriteAllText($project.FullName, $projectContent, $projectEncoding)
        }
    }
}

Write-Host ""
Write-Host "🎉 Migration and package updates completed!"
