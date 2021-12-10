VERSION=$(grep version pom.xml | sed -n '3p' | sed -E 's/\s|[a-z]|<|>|\///g'| cut -d'-' -f'1')
RELEASE_BRANCH=release/$VERSION
git branch $RELEASE_BRANCH
git checkout $RELEASE_BRANCH

mvn -B release:prepare

git branch ${RELEASE_BRANCH}-tomaster HEAD~1
git push origin ${RELEASE_BRANCH}-tomaster

#Create pull request from tag commit to master
RESPONSE=$(curl --tgosling-genesis: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 -X POST -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/tgosling-genesis/test-release/pulls  -d '{"title":"Automatic PR created from release","head":"'${RELEASE_BRANCH}'-tomaster","base":"master"}')
echo 'HTTP RESPONSE '$RESPONSE 
PR_NUMBER=$(echo $RESPONSE |  grep -Eo "\"number\":\s*[0-9]+" | cut -d' ' -f'2')
echo 'PR NUMBER IS '$PR_NUMBER
#Merge the pull request
RESPONSE=$(curl --tgosling-genesis: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 -X PUT -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/tgosling-genesis/test-release/pulls/$PR_NUMBER/merge  -d '{"commit_title":"Automatic merge of '$RELEASE_BRANCH' to master","merge_method":"merge"}')
echo 'HTTP RESPONSE '$RESPONSE 

#Create pull request from snapshot roll to develop
RESPONSE=$(curl --tgosling-genesis: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 -X POST -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/tgosling-genesis/test-release/pulls  -d '{"title":"Automatic PR created from release","head":"'${RELEASE_BRANCH}'","base":"develop"}')
echo 'HTTP RESPONSE '$RESPONSE 
PR_NUMBER=$(echo $RESPONSE |  grep -Eo "\"number\":\s*[0-9]+" | cut -d' ' -f'2')
echo 'PR NUMBER IS '$PR_NUMBER
#Merge the pull request
RESPONSE=$(curl --tgosling-genesis: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 -X PUT -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/tgosling-genesis/test-release/pulls/$PR_NUMBER/merge  -d '{"commit_title":"Automatic merge of '$RELEASE_BRANCH' to develop","merge_method":"merge"}')
echo 'HTTP RESPONSE '$RESPONSE 
  
# Delete temp branch
git branch -d ${RELEASE_BRANCH}-tomaster
git push origin --delete ${RELEASE_BRANCH}-tomaster

mvn release:perform