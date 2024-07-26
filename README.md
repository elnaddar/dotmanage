
# DotManage

DotManage is a tool for managing and generating .NET project templates.

## Features
- Generate controller, model, and view files from templates.
- Easy to use shell script for template creation.

## Folder Structure
```
dotmanage/
├── script/
│   ├── src/
│   │   └── create.sh
│   ├── templates/
│   │   ├── Controller.cs.template
│   │   ├── Model.cs.template
│   │   └── View.cshtml.template
│   └── dotmanage
├── README.md
├── CHANGELOG.md
└── LICENSE
```

## Getting Started

### Prerequisites
- Shell (bash, zsh, etc.)
- ASP.NET MVC Project

### Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/elnaddar/dotmanage.git
   cd dotmanage/script
   ```
2. Ensure the `dotmanage` script is executable:
   ```sh
   chmod +x dotmanage
   ```

### Usage
1. Navigate to your .NET project directory containing the `.csproj` file.
2. Run the `dotmanage` script with the `create` command:
   ```sh
   /path/to/dotmanage create [arguments]
   ```
   Replace `[arguments]` with any necessary arguments for your specific templates.

## Contributing
Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
