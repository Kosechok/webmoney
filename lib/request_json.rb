module Webmoney::RequestJSON

  def json_events_create_post(opt)
    body = {
      groupUid: opt[:group_id],
      postText: opt[:text]
    }

  end

  def json_events_create_comment(opt)
    body = {
      eventId: opt[:post_id],
      parentId: opt[:parent_id] || 0,
      postText: opt[:text]
    }

  end
end