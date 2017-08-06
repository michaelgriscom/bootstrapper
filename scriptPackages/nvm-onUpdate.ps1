# try to set the nvm version to LTS. Unfortunately nvm-windows doesn't have support for this like nvm
# issue tracked at https://github.com/coreybutler/nvm-windows/issues/247

$availableVersions = nvm list available # gets a table of latest versions
$latestLts = $availableVersions[3].split('|')[2].trim() # the table has headers, data starts at the third row. The second column is LTS.

echo "Attempting to install version $latestLts"
nvm install $latestLts
nvm use $latestLts

refreshenv
echo "Installing base npm packages"
npm install -g npm webpack jasmine typescript