cask "dissectmac" do
  version "20260724"

  on_arm do
    sha256 "115367d7caef84044cc3d15da6b2f71606b74013f7cf4e927cc66aeab5e5b4e3"

    url "https://pub-ce87a2625bef4c2dae47d7d3202def2e.r2.dev/DissectMac.dmg"
  end
  on_intel do
    sha256 "0ef1b3016b14620564d79c8c509a55cc4e8bf78ebd183ecec6bf632adbbc9113"

    url "https://pub-ce87a2625bef4c2dae47d7d3202def2e.r2.dev/DissectMac-x64.dmg"
  end

  name "DissectMac"
  desc "Storage analyzer and disk visualizer"
  homepage "https://dissectmac.com/"

  livecheck do
    skip "Unversioned URL — detection handled by scripts/bump-dissectmac.sh and GHA workflow"
  end

  depends_on macos: :big_sur

  app "DissectMac.app"

  zap trash: [
    "~/Library/Application Support/DissectMac",
    "~/Library/Caches/com.kapilkumar.dissect-mac",
    "~/Library/HTTPStorages/com.kapilkumar.dissect-mac",
    "~/Library/Logs/DissectMac",
    "~/Library/Preferences/com.kapilkumar.dissect-mac.plist",
    "~/Library/Saved Application State/com.kapilkumar.dissect-mac.savedState",
    "~/Library/WebKit/com.kapilkumar.dissect-mac",
  ]
end
