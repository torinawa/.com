<#
.SYNOPSIS
    Creates a new Jekyll post file with the correct naming convention and front matter.
.DESCRIPTION
    This script prompts for a post title, generates a slug from it, and creates a new
    markdown file in the '_posts' directory. The filename follows the Jekyll
    format: YYYY-MM-DD-title-slug.md.
.PARAMETER Title
    The title of the new blog post. This will be used for the front matter and to generate the filename slug.
.PARAMETER Author
    The author of the blog post. If not provided, the script will attempt to read from a .author file in the script's directory.
.EXAMPLE
    .\New-Post.ps1 -Title "My First Post"

    This command creates a file named like '2023-10-27-my-first-post.md' in the '_posts'
    directory with the appropriate front matter.
.EXAMPLE
    .\New-Post.ps1 -Title "My First Post" -Author "John Doe"

    This command creates a file with the specified author in the front matter.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Enter the title for the new post.")]
    [string]$Title,

    [Parameter(Mandatory = $false, Position = 1, HelpMessage = "Enter the author name for the post.")]
    [string]$Author
)

try {
    # Determine the author to use
    $authorToUse = $null
    if (-not [string]::IsNullOrWhiteSpace($Author)) {
        # Use the provided Author parameter
        $authorToUse = $Author
    }
    else {
        # Check if .author file exists
        $authorFilePath = Join-Path -Path $PSScriptRoot -ChildPath ".author"
        if (Test-Path -Path $authorFilePath) {
            $authorToUse = (Get-Content -Path $authorFilePath -Raw).Trim()
            Write-Verbose "Using author from .author file: $authorToUse"
        }
    }

    # Get the current date in YYYY-MM-DD format
    $currentDate = Get-Date -Format "yyyy-MM-dd"

    # Create a URL-friendly slug from the title
    # 1. Convert to lowercase
    # 2. Replace spaces with hyphens
    # 3. Remove characters that are not alphanumeric or hyphens
    $slug = $Title.ToLower().Replace(" ", "-") -replace '[^a-z0-9-]', ''

    # Define the directory for posts
    $postsDirectory = Join-Path -Path $PSScriptRoot -ChildPath "_posts"

    # Create the _posts directory if it doesn't exist
    if (-not (Test-Path -Path $postsDirectory)) {
        Write-Verbose "Creating directory: $postsDirectory"
        New-Item -Path $postsDirectory -ItemType Directory -Force | Out-Null
    }

    # Construct the full file path and name
    $fileName = "$($currentDate)-$($slug).md"
    $filePath = Join-Path -Path $postsDirectory -ChildPath $fileName

    # Check if a file with the same name already exists
    if (Test-Path -Path $filePath) {
        throw "A post with the name '$fileName' already exists."
    }

    if (-not [string]::IsNullOrWhiteSpace($authorToUse)) {
        $fileContent = @"
---
layout: post
title: "$Title"
date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
categories:
author: $authorToUse
---
"@
    }
    else {
        $fileContent = @"
---
layout: post
title: "$Title"
date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
categories:
---
"@
    }

    # Create the new post file with the front matter
    Write-Verbose "Creating new post file: $filePath"
    Set-Content -Path $filePath -Value $fileContent -Encoding UTF8

    Write-Host "Successfully created new post: $filePath"

}
catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
}