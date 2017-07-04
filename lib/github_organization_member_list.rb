require "github_organization_member_list/version"

require 'octokit'
require 'thor'
require 'highline/import'

require 'erb'
require 'erb_with_hash'

module GithubOrganizationMemberList
  class Team
    attr_reader :members, :repositories
    def initialize(team_params, members: , repositories: )
      @team = team_params
      @members = members
      @repositories = repositories
    end

    def member?(member_id)
      @members.any? {|m| m[:id] == member_id }
    end

    def name
      @team[:name]
    end

    def repository_names
      @repositories.map {|r| r[:name] }
    end
  end

  class OrganizationViewer
    attr_reader :organization
    def initialize(organization: , token: )
      @organization = organization
      @client = Octokit::Client.new(access_token: token)
    end

    def report_member_with_teams_and_repositories
      @members.map do |member|
        joined_teams = @team.find_all {|t| t.member?(member[:id]) }
        member_template.result_with_hash(login: member[:login], joined_teams: joined_teams)
      end
    end

    def member_template
      @member_template ||= ERB.new(<<-'EOS', nil, '-')
<%= login %>|<%= joined_teams.map(&:name).join(',') %>|<%= joined_teams.flat_map(&:repository_names).uniq.join(',') %>
      EOS
    end

    def fetch!
      fetch_members!
      fetch_team!
    end

    def fetch_members!
      @members = client.organization_members(@organization)
    end

    def fetch_team!
      @team = client.organization_teams(@organization).map do |team|
        GithubOrganizationMemberList::Team.new(
          team,
          members: @client.team_members(team[:id]),
          repositories: @client.team_repositories(team[:id])
        )
      end
    end

    private

    def client
      @client
    end
  end

  class Command < Thor
    desc 'org_name', 'hi'
    def members(org, *args)
      Octokit.auto_paginate = true
      token = ask("Enter GitHub OAuth token") { |q| q.echo = false }
      viewer = OrganizationViewer.new(organization: org, token: token)
      viewer.fetch!
      viewer.report_member_with_teams_and_repositories.each do |line|
        puts line
      end
    end
  end
end
