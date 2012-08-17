# MaxColumnsPlugin 0.2

A OS X Mail.app plugin to trim trailing whitespaces and wrap your emails to 80 columns.  
Only tidy up plain text messages (either use "Format > Convert to plain text format" when writing your mail, or make it the default in Mail's preferences).

## Compatibility

Developed for OS X Lion 10.7.4, with Mail.app 5.3 and Message.framework 5.3.  
You can enable the plugin to support other versions of Mail with the following procedure (but keep in mind that it will not have been tested):

Open up Terminal (_/Applications/Utilities/Terminal.app_) and type

    defaults read /Applications/Mail.app/Contents/Info PluginCompatibilityUUID
    defaults read /System/Library/Frameworks/Message.framework/Resources/Info PluginCompatibilityUUID

This should print to UUIDs like these ones:

    4C286C70-7F18-4839-B903-6F2D58FA4C71
    EF59EC5E-EFCD-4EA7-B617-6C5708397D24

Add these to the _SupportedPluginCompatibilityUUIDs_ value in the bundle's Info.plist file (_MaxColumnsPlugin.mailbundle/Contents/Info.plist_).
This is what the Info.plist looks like with the Mail and Message.framework 5.3 UUIDs:

    <key>SupportedPluginCompatibilityUUIDs</key>
    <array>
        <string>EF59EC5E-EFCD-4EA7-B617-6C5708397D24</string>
        <string>4C286C70-7F18-4839-B903-6F2D58FA4C71</string>
    </array>

## Installation

Stop Mail.

Tell Mail to enable the support for bundles, if you didn't do it already:

    % defaults write com.apple.mail EnableBundles -bool true
    % defaults write com.apple.mail BundleCompatibilityVersion 3

Copy the plugin MaxColumnsPlugin.mailbundle to the Mail.app plugins folder:

    % cp MaxColumnsPlugin.mailbundle $(HOME)/Library/Mail/Bundles/

Restart Mail.

## I want to wrap at 120 columns !

Just edit the _MCMaxColumnsWrap_ value in the bundle's Info.plist file (_MaxColumnsPlugin.mailbundle/Contents/Info.plist_).

    <key>MCMaxColumnsWrap</key>
    <integer>120</integer>  # Put the value you want here

## As is - No warranty

TL;DR : If this breaks your system / your mails, don't blame me.

The program is distributed in the hope that it will be useful, but without any warranty. It is provided "as is" without warranty of any kind, either expressed or implied, including, but not limited to, the implied warranties of merchantability and fitness for a particular purpose. The entire risk as to the quality and performance of the program is with you. Should the program prove defective, you assume the cost of all necessary servicing, repair or correction.

In no event unless required by applicable law the author will be liable to you for damages, including any general, special, incidental or consequential damages arising out of the use or inability to use the program (including but not limited to loss of data or data being rendered inaccurate or losses sustained by you or third parties or a failure of the program to operate with any other programs), even if the author has been advised of the possibility of such damages.

## License

DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
Version 2, December 2004 

Copyright (C) 2012 Guillaume Algis <guillaume.algis@gmail.com> 

Everyone is permitted to copy and distribute verbatim or modified 
copies of this license document, and changing it is allowed as long 
as the name is changed. 

DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION 

0. You just DO WHAT THE FUCK YOU WANT TO. 
