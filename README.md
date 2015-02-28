# jvc

jvc is a command-line utility for browsing Jeuxvideo.com forums.

###Usage

`jvc forum <forum_id>` : Show the first page threads     
`jvc forum <forum_alias` : Show the first page threads for the forum defined by alias     
`jvc alias forum <alias_name> <forum_id>` : Define an alias for a forum    
`jvc alias topic <alias_name> <topic_id>` : Define an alias for a topic     
`jvc topic <forum_id/alias> <topic_id/alias>` : Show the last page of this topic      
`jvc topic <forum_id/alias> <topic_id/alias> <page_number>` : Show the specified page for this topic       
`jvc name <forum_id>` : Get the name of the forum       
`jvc search <keyword>` : Search forums with <keyword> in their names      

###Dependencies

- Ruby
- Nokogiri (`gem install nokogiri`)
