# Stop script on first error
set -o errexit

# Prevent "Please tell me who you are" errors for certain DZIL configs
git config --global user.name 'github-actions'

# check perl version
perl --version

#
# Install Dist::Zilla and module dependencies
#

cpanm -n Dist::Zilla

# Install DZIL plugins etc if needed
cd $GITHUB_WORKSPACE
dzil authordeps --missing | grep -vP '[^\w:]' | xargs cpanm -n
dzil listdeps --missing --cpanm | grep -vP '[^\w:~"\.]' | xargs cpanm -n

# dependencies of module tests
cpanm -n HTTP::Server::Simple

#
# Run tests (user tests as well as maintainer tests)
#

prove --verbose -l -s -r t
