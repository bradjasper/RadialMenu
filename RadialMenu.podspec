Pod::Spec.new do |s|

    s.name              = 'RadialMenu'
    s.version           = '0.0.1'
    s.summary           = 'A custom radial menu control (like the one from iMessage in iOS 8)'
    s.homepage          = 'https://github.com/bradjasper/radialmenu'
    s.license           = {
        :type => 'MIT',
        :file => 'LICENSE'
    }
    s.author            = {
        'Brad Jasper' => 'contact@bradjasper.com'
    }
    s.source            = {
        :git => 'https://github.com/bradjasper/radialmenu.git',
        :tag => s.version.to_s
    }
    s.source_files      = 'RadialMenu/*'
    s.requires_arc      = true
    s.dependency 'pop'
    s.platform          = :ios, '8.0'

end
