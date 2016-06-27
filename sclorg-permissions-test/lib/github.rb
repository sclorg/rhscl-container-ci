require 'rest_client'
require 'json'

RESULTS_PER_PAGE=100

def github_org_to_teams
  {
    :sclorg => github_teams('sclorg'),
  }
end

def github_teams(org_name)
  params = access_params
  result = RestClient.get("https://api.github.com/orgs/#{org_name}/teams", {:params => params})
  JSON.parse(result)
end

def team_red_hat
  params = access_params
  result = RestClient.get("https://api.github.com/teams/168397", {:params => params})
  JSON.parse(result)
end

def github_team_users(team)
  params = access_params
  result = []
  length = RESULTS_PER_PAGE
  page = 1
  while length == RESULTS_PER_PAGE
    params['page'] = page
    next_result = RestClient.get(team['url'] + '/members', {:params => params})
    next_result = JSON.parse(next_result)
    length = next_result.length
    result += next_result
    page += 1
  end
  result
end

def github_team_repos(team)
  params = access_params
  result = []
  length = RESULTS_PER_PAGE
  page = 1
  while length == RESULTS_PER_PAGE
    params['page'] = page
    next_result = RestClient.get(team['url'] + '/repos', {:params => params})
    next_result = JSON.parse(next_result)
    length = next_result.length
    result += next_result
    page += 1
  end
  result
end

def github_repo_collaborators(repo)
  params = access_params
  result = []
  length = RESULTS_PER_PAGE
  page = 1
  while length == RESULTS_PER_PAGE
    params['page'] = page
    next_result = RestClient.get(repo['url'] + '/collaborators', {:params => params})
    next_result = JSON.parse(next_result)
    length = next_result.length
    result += next_result
    page += 1
  end
  result
end

def github_issues
  params = access_params(false)
  result = []
  length = RESULTS_PER_PAGE
  page = 1
  while length == RESULTS_PER_PAGE
    params['page'] = page
    next_result = RestClient.get("https://api.github.com/repos/openshift/origin/issues", {:params => params})
    next_result = JSON.parse(next_result)
    length = next_result.length
    result += next_result
    page += 1
  end
  result
end

def github_user(user)
  params = access_params
  result = RestClient.get(user['url'], {:params => params})
  JSON.parse(result)
end

private

def access_params(require_access_token=true)
  params = {:per_page => RESULTS_PER_PAGE}
  access_token = ENV['GH_ACCESS_TOKEN']
  if access_token
    params[:access_token] = access_token
  elsif require_access_token
    raise "Missing environment variable: GH_ACCESS_TOKEN"
  end
  params
end
