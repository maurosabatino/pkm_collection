# =========================================================
#  PKMCollection - Tuist Project Makefile
# =========================================================

# Path to Tuist binary if installed
TUIST := $(shell which tuist 2>/dev/null)

.DEFAULT_GOAL := bootstrap

# ---------------------------------------------------------
# 🧩 UTILITY TARGETS
# ---------------------------------------------------------

check-tuist:
	@echo "🔍 Checking Tuist installation..."
	@if [ -z "$(TUIST)" ]; then \
		echo "⚠️  Tuist not found. Installing..."; \
		curl -Ls https://install.tuist.io | bash; \
	else \
		echo "✅ Tuist found at $(TUIST)"; \
	fi

# ---------------------------------------------------------
# 🧹 CLEANUP TARGETS
# ---------------------------------------------------------

clean:
	@echo "🧼 Cleaning Tuist cache and build artifacts..."
	tuist clean || true
	rm -rf DerivedData
	rm -rf .tuist/Dependencies
	@echo "✅ Clean complete."

fix-lock:
	@echo "🧹 Killing stuck SwiftPM/Tuist processes..."
	@pkill -f swift-build || true
	@pkill -f swift-package || true
	@pkill -f tuist || true
	rm -rf Tuist/.build
	rm -rf .tuist/Dependencies
	@echo "✅ Locks removed. Ready to reinstall."

# ---------------------------------------------------------
# 🚀 BOOTSTRAP & BUILD
# ---------------------------------------------------------

bootstrap: check-tuist
	@echo "🚀 Bootstrapping PKMCollection..."
	make fix-lock
	tuist clean
	tuist install
	tuist generate
	@echo "✅ Project generated successfully!"

refresh:
	@echo "🔁 Full refresh..."
	make clean
	make bootstrap

# ---------------------------------------------------------
# 🧭 OPEN PROJECT
# ---------------------------------------------------------

open:
	@echo "🧩 Generating and opening project in Xcode..."
	tuist generate
	open PKMCollection.xcodeproj

focus:
	@echo "🎯 Generating and focusing on a single module..."
	@read -p 'Enter module name (e.g. CoreKit, UIComponents): ' module; \
	tuist focus --path "Modules/$$module"

# ---------------------------------------------------------
# 🆘 HELP
# ---------------------------------------------------------

help:
	@echo ""
	@echo "Available Makefile commands:"
	@echo "  make bootstrap    - Verify Tuist, clean locks, install deps, generate project"
	@echo "  make open         - Generate and open project in Xcode"
	@echo "  make focus        - Generate only a specific module (faster builds)"
	@echo "  make clean        - Remove DerivedData, Tuist cache, and dependencies"
	@echo "  make fix-lock     - Kill stuck SwiftPM/Tuist processes and remove locks"
	@echo "  make refresh      - Full clean + bootstrap"
	@echo "  make help         - Show this help message"
	@echo ""

