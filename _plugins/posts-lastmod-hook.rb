#!/usr/bin/env ruby
#
# Custom plugin for k-reel.github.io
# Automatically sets last_modified_at from git history
# Author: Kirill Boychenko
#

Jekyll::Hooks.register :posts, :post_init do |post|
  # Count commits for this post file
  commit_num = `git rev-list --count HEAD "#{ post.path }"`

  # Only set last_modified_at if post has been updated (more than 1 commit)
  if commit_num.to_i > 1
    lastmod_date = `git log -1 --pretty="%ad" --date=iso "#{ post.path }"`
    post.data['last_modified_at'] = lastmod_date
  end
end
