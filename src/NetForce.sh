#!/bin/bash

check_dotnet() {
  # Check if dotnet is installed
  if ! command -v dotnet &> /dev/null
  then
    echo "Dotnet could not be found. Please install it and try again."
    echo "https://dotnet.microsoft.com/download"
    exit
  fi
}

# Function to list available .NET Core templates
list_templates() {
  echo "Available .NET Core templates:"
  dotnet new -l
}

# Function to create a new .NET Core solution
create_add_solution() {
  add_to_solution=$1
  actual_solution_path=$(pwd)
  # convert add_to_solution to lowercase
  add_to_solution=$(echo "$add_to_solution" | tr '[:upper:]' '[:lower:]')
  if [ "$add_to_solution" == "y" ]; then
    # Prompt for solution path
    read -r -p "Enter solution path: " solution_path

    # Add the project to the solution
    dotnet sln add "$solution_path/$project_name.csproj"
    echo "Project $project_name added to solution successfully!"
    #store the solution path in a variable
    actual_solution_path=$solution_path
  else
    # Prompt for solution name
    read -r -p "Enter solution name: " solution_name

    # Create the solution
    dotnet new sln -n "$solution_name"

    # Add the project to the solution
    dotnet sln add "$solution_name/$project_name.csproj"
    echo "Project $project_name added to the new solution successfully!"
    #store the solution path in a variable
    actual_solution_path=$solution_name
  fi
  return "$actual_solution_path"
}

# Function to create a new .NET Core project
#accept parameters in this function for project
create_project() {
  project_type=$1
  project_name=$2
  # check if we already have a folder with project name, if yes then prompt the user to change the project name else create the new project
  if [ -d "$project_name" ]; then
    echo -e "\e[31mError: Directory $project_name already exists!!\e[0m"
    read -r -p "Do you want to change the project name? (y/n/Y/N): " choice
    # convert choice to lowercase
    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')
    if [ "$choice" == "y" ]; then
      # Prompt for project name
      read -r -p "Enter project name: " project_name
    else
      echo "Project creation aborted!!"
      return
    fi
  fi
  # Create the project
  dotnet new "$project_type" -n "$project_name"
  echo "Project $project_name created successfully!"
  return "$project_name"
}

netForce_create_project(){

  #-----------STEP 1: CREATE PROJECT DIRECTORY----------------
  # Prompt for directory path (enter $PWD for current directory)
  read -r -p "Enter directory path (PWD for current directory): " directory_path

  # Store current directory to a variable
  current_directory=$(pwd)

  if [ "$directory_path" == "PWD" ]; then
    directory_path=$current_directory
  fi

  # Display a message
  echo "Changing directory to $directory_path ......"

  # If the directory does not exist display an error message and ask if to create a new one else switch to that directory
  if [ ! -d "$directory_path" ]; then
    echo -e "\e[31mError: Directory $directory_path does not exist!!\e[0m"

    # Ask the user if they want to create the directory
    read -r -p "Do you want to create the directory? (y/n/Y/N): " choice
    # convert create_directory to lowercase
    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')
    if [ "$choice" == "y" ]; then
      # Create the directory
      mkdir "$directory_path"
      echo "Directory $directory_path created successfully!"
      # Switch to the directory
      cd "$directory_path" || return
    else
      return
    fi
  else
    cd "$directory_path" || return
  fi
  cd "$current_directory" || return

  #-----------STEP 2: CREATE PROJECT----------------
  # Prompt for project type and name
  read -r -p "Enter project type (e.g. console, classlib): " project_type
  read -r -p "Enter project name: " project_name

  # Create the project by calling create_project function and capture the result in project_name variable
  project_name=$(create_project "$project_type" "$project_name")

  #-----------STEP 3: CREATE SOLUTION----------------
  # Prompt the user if he wants to add the new project to an existing solution or create a new solution
  read -r -p "Do you want to add the project to an existing solution? (y/n/Y/N): " add_to_solution
  # call the function to create the solution or add the project to it and store the return value in a variable
  actual_solution_path=$(create_add_solution "$add_to_solution")
  
  #-----------STEP 4: OPEN PROJECT in VSCODE----------------
  # Prompt the user if he wants to open the folder in vscode
  read -r -p "Do you want to open the folder in vscode? (y/n/Y/N): " open_vscode
  # convert open_vscode to lowercase
  open_vscode=$(echo "$open_vscode" | tr '[:upper:]' '[:lower:]')
  #check if vscode installed , if yes open folder otherwise display error message
  if [ "$open_vscode" == "y" ]; then
    if command -v code &> /dev/null
    then
      code "$directory_path"
    else
      echo "Visual Studio Code could not be found. Please install it and try again."
      echo "https://code.visualstudio.com/download"
    fi
  fi


}


# Function to add a project to the solution
add_project() {
  # Prompt for project type, name and solution path
  read -r -p "Enter project type (e.g. console, classlib): " project_type
  read -r -p "Enter project name: " project_name
  read -r -p "Enter solution path: " solution_path

  # Create the project
  dotnet new "$project_type" -n "$project_name"

  # Add the project to the solution
  dotnet sln add "$solution_path/$project_name.csproj"
  echo "Project $project_name added to solution successfully!"
}

# Function to add a project to the solution
create_project_and_solution() {
  
  # Prompt for directory path (enter $PWD for current directory)
  read -r -p "Enter directory path: " directory_path

  # Prompt for project type, name and solution path
  read -r -p "Enter project type (e.g. console, classlib): " project_type
  read -r -p "Enter project name: " project_name
  read -r -p "Enter solution name: " solution_path
  
  cd "$directory_path" || return

  # Create the project
  dotnet new "$project_type" -n "$project_name"

  # Add the project to the solution
  dotnet sln add "$solution_path/$project_name.csproj"
  echo "Project $project_name added to solution successfully!"
}

create_custom_templates(){
    # Prompt for project path
    read -r -p "Enter project path: " project_path

    # Prompt for template name and type
    read -r -p "Enter template output path: " template_path

    # Prompt for template name and type
    read -r -p "Enter template name: " template_name
    read -r -p "Enter template type (e.g. console, classlib): " template_type

    # Create the template
    dotnet new -i "$template_name" -n "$template_name" -o "$template_name"

    # Prompt for author name
    read -r -p "Enter author name: " author_name

    # Update the template manifest with the author name
    sed -i "s/My Company/$author_name/g" "$template_name/.template.config/template.json"

    # Pack the template
    dotnet new -p "$template_name"

    echo "Custom template $template_name created successfully!"
}


# Main menu
while true; do
  echo "Interactive .NET Core Solution Creator"
  echo "-----------------------------"
  echo "1. List available templates"
  echo "2. Create new project"
  echo "3. Add project to solution"
  echo "4. Create custom template"
  echo "5. Exit"
  read -r -p "Enter your choice: " choice

  case $choice in
    1) list_templates;;
    2) netForce_create_project;;
    3) add_project;;
    4) create_custom_templates;;
    5) exit;;
    *) echo "Invalid choice. Try again.";;
  esac
done
