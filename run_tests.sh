#!/bin/bash

# Test runner script for Mouse Toucher

echo "=== Mouse Toucher Test Suite ==="
echo ""

# Run tests using Swift Package Manager
echo "🧪 Running tests with Swift Package Manager..."
swift test

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 All tests passed!"
    exit 0
else
    echo ""
    echo "💔 Some tests failed"
    exit 1
fi
