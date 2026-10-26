package database

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	_ "github.com/lib/pq"
)

type DB struct {
	SQL *sql.DB
}

// Connect initializes a connection pool to PostgreSQL per Article 22 & 23
func Connect(databaseURL string) (*DB, error) {
	if databaseURL == "" {
		return nil, fmt.Errorf("DATABASE_URL is empty; running in stand-alone in-memory mode")
	}

	db, err := sql.Open("postgres", databaseURL)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	// Connection Pool Configuration for Production Load
	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(10)
	db.SetConnMaxLifetime(5 * time.Minute)
	db.SetConnMaxIdleTime(2 * time.Minute)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := db.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	log.Println("[DATABASE] Successfully connected to PostgreSQL cluster.")
	return &DB{SQL: db}, nil
}

// Ping verifies active database connectivity for /readyz health checks
func (d *DB) Ping(ctx context.Context) error {
	if d == nil || d.SQL == nil {
		return fmt.Errorf("database client not initialized")
	}
	return d.SQL.PingContext(ctx)
}

// RunMigrationFile applies a SQL schema migration file
func (d *DB) RunMigrationFile(ctx context.Context, filePath string) error {
	if d == nil || d.SQL == nil {
		return fmt.Errorf("database client not initialized")
	}

	content, err := os.ReadFile(filePath)
	if err != nil {
		return fmt.Errorf("cannot read migration file %s: %w", filePath, err)
	}

	tx, err := d.SQL.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback()

	if _, err := tx.ExecContext(ctx, string(content)); err != nil {
		return fmt.Errorf("failed to execute migration %s: %w", filePath, err)
	}

	if err := tx.Commit(); err != nil {
		return fmt.Errorf("failed to commit migration: %w", err)
	}

	log.Printf("[DATABASE] Migration %s applied successfully.", filePath)
	return nil
}

