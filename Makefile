test:
	xcodebuild -project "Pareto Updater.xcodeproj" -clonedSourcePackagesDirPath SourcePackages -scheme "Pareto Updater" -configuration Debug -resultBundlePath test.xcresult -destination platform=macOS test 

build:
	xcodebuild -project "Pareto Updater.xcodeproj" -clonedSourcePackagesDirPath SourcePackages -scheme "Pareto Updater" -configuration Debug -destination platform=macOS build

libSetapp:
	wget "https://developer-api.setapp.com/v1/applications/496/kevlar?token=${SETAPP_TOKEN}&type=libsetapp_silicon" -O libsetapp.zip
	unzip libsetapp.zip
	rm libsetapp.zip

archive-debug:
	xcodebuild -project "Pareto Updater.xcodeproj" -clonedSourcePackagesDirPath SourcePackages -scheme "Pareto Updater" -destination platform=macOS archive -archivePath app.xcarchive -configuration Debug -allowProvisioningUpdates
	xcodebuild -exportArchive -archivePath app.xcarchive -exportPath Export -exportOptionsPlist exportOptionsDev.plist

archive-debug-setapp: libSetapp
	xcodebuild -project "Pareto Updater.xcodeproj" -clonedSourcePackagesDirPath SourcePackages -scheme "Pareto Updater SetApp" -destination platform=macOS archive -archivePath setapp.xcarchive -configuration Debug -allowProvisioningUpdates
	xcodebuild -exportArchive -archivePath setapp.xcarchive -exportPath SetAppExport -exportOptionsPlist exportOptionsDev.plist
	mv SetAppExport/Pareto\ Updater\ SetApp.app SetAppExport/Pareto\ Updater.app

archive-release:
	xcodebuild -project "Pareto Updater.xcodeproj" -clonedSourcePackagesDirPath SourcePackages -scheme "Pareto Updater" -destination platform=macOS archive -archivePath app.xcarchive -configuration Release -allowProvisioningUpdates
	xcodebuild -exportArchive -archivePath app.xcarchive -exportPath Export -exportOptionsPlist exportOptions.plist


archive-release-setapp: libSetapp
	rm -rf SetAppExport
	xcodebuild -project "Pareto Updater.xcodeproj" -clonedSourcePackagesDirPath SourcePackages -scheme "Pareto Updater SetApp" -destination platform=macOS archive -archivePath setapp.xcarchive -configuration Release -allowProvisioningUpdates
	xcodebuild -exportArchive -archivePath setapp.xcarchive -exportPath SetAppExport -exportOptionsPlist exportOptions.plist
	mv SetAppExport/Pareto\ Updater\ SetApp.app SetAppExport/Pareto\ Updater.app

build-release-setapp:
	# rm -f ParetoUpdaterSetApp.app.zip
	# rm -rf SetAppExport/Release
	# mkdir -p SetAppExport/Release
	# cp assets/Mac_512pt@2x.png SetAppExport/Release/AppIcon.png
	# cp -vr SetAppExport/Pareto\ Updater.app SetAppExport/Release/Pareto\ Updater.app
	# cd SetAppExport; ditto -c -k --sequesterRsrc --keepParent Release ../ParetoUpdaterSetApp.app.zip
	cp -f assets/Mac_512pt@2x.png AppIcon.png
	zip -u ParetoUpdaterSetApp.app.zip AppIcon.png
	rm -f AppIcon.png

dmg:
	create-dmg --overwrite Export/Pareto\ Updater.app Export && mv Export/*.dmg ParetoUpdater.dmg

pkg:
	productbuild --scripts ".github/pkg" --component Export/Pareto\ Updater.app / ParetoUpdaterPlain.pkg
	productsign --sign "Developer ID Installer: Niteo GmbH" ParetoUpdaterPlain.pkg ParetoUpdater.pkg

lint:
	mint run swiftlint .

fmt:
	mint run swiftformat --swiftversion 5 .
	mint run swiftlint . --fix

notarize-dmg:
	xcrun notarytool submit ParetoUpdater.dmg --team-id PM784W7B8X --progress --wait

notarize-zip:
	xcrun notarytool submit ParetoUpdater.zip --team-id PM784W7B8X --progress --wait

clean:
	rm -rf SourcePackages
	rm -rf Export
	rm -rf SetAppExport

zip:
	ditto -V -c -k --keepParent Export/Pareto\ Updater.app ParetoUpdater.zip

sentry-debug-upload:
	sentry-cli --auth-token ${SENTRY_AUTH_TOKEN} upload-dif app.xcarchive --org teamniteo --project pareto-mac

sentry-debug-upload-setapp:
	sentry-cli --auth-token ${SENTRY_AUTH_TOKEN} upload-dif setapp.xcarchive --org teamniteo --project pareto-mac