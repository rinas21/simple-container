# Makefile for building and managing the simple container program

# Compiler
CC = gcc

# Compiler flags
# -Wall: Enable all warnings
# -Wextra: Enable extra warnings
# -static: Build a statically linked binary
# -O2: Optimize for speed
# -g: Include debugging information
CFLAGS = -Wall -Wextra -static -O2 -g

# Target executable name
TARGET = simple-container

# Source files
SRCS = simple-container.c

# Default rule: Build the target
all: $(TARGET)

# Rule to build the target executable
$(TARGET): $(SRCS)
		@echo "Compiling $(TARGET)..."
		$(CC) $(CFLAGS) -o $(TARGET) $(SRCS)
		@echo "✅ Build complete: $(TARGET)"

# Rule to clean up build artifacts
clean:
		@echo "Cleaning up..."
		rm -f $(TARGET)
		@echo "✅ Clean complete"

# Rule to rebuild the project (clean + build)
rebuild: clean all

# Rule to run the program (for convenience)
run: $(TARGET)
		@echo "Running $(TARGET)..."
		./$(TARGET)

# Phony targets to prevent conflicts with files named 'clean', 'all', etc.
.PHONY: all clean rebuild run

