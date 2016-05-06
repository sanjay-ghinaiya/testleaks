Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '8.0'
s.name = "TGLeaks"
s.summary = "TGLeaks lets a user can get leaks."
s.requires_arc = true

# 2
s.version = "0.1.1"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "TestGrid Team" => "info@testgrid.io" }

# 5 - Replace this URL with your own Github page's URL (from the address bar)
s.homepage = "https://github.com/sanjay-ghinaiya/testleaks"

# For example,
# s.homepage = "https://github.com/JRG-Developer/RWPickFlavor"


# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/sanjay-ghinaiya/testleaks.git", :tag => "#{s.version}"}

# For example,
# s.source = { :git => "https://github.com/JRG-Developer/RWPickFlavor.git", :tag => "#{s.version}"}


# 7
s.framework = "UIKit"
s.framework = "CoreGraphics"
s.framework = "Foundation"
s.dependency 'FBMemoryProfiler' , '~> 0.1.1’

# 8
s.source_files = "TGLeaks/**/*.{h,m}"

# 9
#s.resources = "TGLeaks/**/*.{png,jpeg,jpg,storyboard,xib}"
end