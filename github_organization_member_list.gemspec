# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'github_organization_member_list/version'

Gem::Specification.new do |spec|
  spec.name          = "github_organization_member_list"
  spec.version       = GithubOrganizationMemberList::VERSION
  spec.authors       = ["takkanm"]
  spec.email         = ["takkanm@gmail.com"]

  spec.summary       = %q{show your organization member with team and repository}
  spec.description   = %q{show your organization member with team and repository}
  spec.homepage      = "https://github.com/takkanm/github_organization_member_list"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'octokit'
  spec.add_dependency 'thor'
  spec.add_dependency 'highline'
  spec.add_dependency 'erb_with_hash'

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
