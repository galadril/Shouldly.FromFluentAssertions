
# 🎯 Purpose of the Script

This script was created to **migrate FluentAssertions** to **Shouldly** in a C# solution. The goal is to simplify the replacement process by automating common changes and reducing manual effort. 💻🔧

While the script aims to cover most cases, it's important to note that:

- 🛠️ It provides a **best-effort approach** and may not handle all edge cases or custom implementations.

- ⚠️ The solution might **not be 100% buildable** after running the script, so further manual verification and adjustments may be required.

----------

# 🚀 How It Works

### 🌟 Key Features

1. **Direct Mappings**: Maps FluentAssertions methods to their equivalent in Shouldly.

2. **AssertionScope Handling**: Removes `using (new AssertionScope())` blocks while keeping the internal lines intact.

3. `**WithMessage**` **Adjustments**: Updates patterns like `.ShouldThrow().WithMessage()` to the appropriate Shouldly equivalent.

4. **Duplicate Usings Cleanup**: Removes duplicate `using` statements for a cleaner codebase.

5. **Package References Update**: Replaces `FluentAssertions` with `Shouldly` in `Directory.Packages.props` or `.csproj` files.

----------

# 📖 Instructions

### 1. 🛠️ **Prepare Your Environment**

- Make sure you have **PowerShell** installed.

- Identify the root folder of your solution (where `.sln` and project files are located).

### 2. ▶️ **Run the Script**

Run the script by providing the path to your solution folder:

```
param(
    [Parameter(Mandatory=$true)]
    [Alias("s")]
    [string]$SolutionPath
)
```

For example:

```
.\Migrate-FluentAssertionsToShouldly.ps1 -SolutionPath "C:\MySolution\Solution.sln"
```

### 3. 🛑 **Post-Script Review**

After running the script:

1. Open your solution in an IDE like Visual Studio.

2. 🔍 Review the changes made to your `.cs` and `.csproj` files.

3. 🧪 Run your tests to ensure everything works as expected.

----------

# 💡 Limitations

- The script assumes common patterns of FluentAssertions usage. Custom or complex cases may require manual adjustments. ✋

- It does **not refactor logic**; only method and package replacements are performed.

- Ensure that you commit your code before running the script to allow easy rollback if needed. 🗂️

----------

# 🎉 Acknowledgments

This script was crafted with 💻 and ❤️ to make your migration journey easier. We hope it saves you time and effort. 🚀

If you have feedback or encounter issues, feel free to contribute or share suggestions. Happy coding! 🥳
