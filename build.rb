require 'yaml'

VERSION = '2.2.0'

$boxes = YAML::load_file(File.join(__dir__, 'boxes.yml'))

$dobi = {
  'meta' => {
    'project' => 'esolang-box',
    'default' => 'all',
  },
  'alias=all' => nil,
}

$langs = []

def iterate(lang, parent = nil, depth = 0)
  lang.each do |key, value|
    unless key.start_with? '_'
      $dobi["image=#{key}"] = {
        'image' => "esolang/#{key}",
        'context' => "boxes/#{key}",
        'tags' => ['latest', VERSION],
        'depends' => if parent then [parent] else [] end,
      }

      unless value['_disabled']
        $langs << key
        if value['_name'].nil? || value['_link'].nil?
          puts "#{' ' * (4 * depth)}* [`esolang/#{key}`](https://hub.docker.com/r/esolang/#{key}/)"
        else
          puts "#{' ' * (4 * depth)}* [`esolang/#{key}`](https://hub.docker.com/r/esolang/#{key}/): [#{value['_name']}](#{value['_link']})"
        end
      end

      iterate value, key, depth + 1
    end
  end
end

iterate $boxes

$dobi['alias=all'] = {
  'tasks' => $langs,
}

File.write File.join(__dir__, 'dobi.yaml'), "# This file is auto-generated from boxes.yml. Please don't edit directly.\n#{$dobi.to_yaml}"

print 'Generated dobi.yaml'
