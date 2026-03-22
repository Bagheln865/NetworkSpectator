## Contributing to NetworkSpectator
Thank you for your interest in contributing! We welcome all types of contributions, from bug reports and documentation improvements to new features and code refactors. 

## 🤝 Code of Conduct
By participating in this project, you agree to abide by our Code of Conduct. We expect all contributors to be respectful, inclusive, and collaborative. 

## 🚀 How to Contribute
### 1. Find or Create an Issue
Before starting work, check the Issue Tracker to see if the task is already being addressed.
If you find a bug or have a feature request, please open a new issue using our templates. 

### 2. Fork and Clone
Fork the repository to your own GitHub account. Clone the fork locally:

```
git clone https://github.com/<your_forked_repo>/NetworkSpectator.git
```

Add the original repository as the upstream remote:
```
git remote add upstream https://github.com/Pankajbawane/NetworkSpectator.git
```

### 3. Create a Topic Branch
- Always create a new branch for your work: 
```
git checkout -b feature/your-feature-name
```
- For new feature or enhancements, prefix branch name with ```feature/```
- For bug fixes, prefix branch name with ```bugfix/```

### 4. Development
- NetworkSpectator is a framework, hence it doesn't run as a standalone app on iOS/MacOS. You can create your own app which makes HTTP requests and add this package as a dependency. Or use the example app created for NetworkSpectator for testing the changes made to the framework locally.
  However, ensure you are pushing your changes to your forked repository and not on NetworkSpectatorExample.
```
  Example app - https://github.com/Pankajbawane/NetworkSpectatorExample
```
- Write unit tests for newly added buisness logic and ensure all tests pass.
- Perform testing and ensure it works as expected without breaking anything.

### 5. Commit and Push
- Write clear, concise commit messages.
- Push your branch to your fork on GitHub:
```
git push origin feature/your-feature-name
```

### 6. Submit a Pull Request
- Navigate to the original NetworkSpectator repository on GitHub and click Compare & pull request.
- Describe your changes clearly in the PR description and link to any related issues.
- Be responsive to feedback from maintainers during the review process. 

## 📏 Coding Standards
- Style: Follow the project's existing indentation and naming conventions.
- Add appropriate comments explaining what the code does.
- Unit Tests: Include unit tests for any features or bug fixes.
- Documentation: Update relevant README or documentation files if required.
