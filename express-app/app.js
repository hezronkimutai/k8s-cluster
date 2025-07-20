const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.static('public'));

// Routes
app.get('/', (req, res) => {
    res.json({
        message: 'Welcome to Simple Express.js App!',
        timestamp: new Date().toISOString(),
        version: '1.0.0',
        environment: process.env.NODE_ENV || 'development',
        hostname: require('os').hostname()
    });
});

app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        hostname: require('os').hostname()
    });
});

app.get('/api/info', (req, res) => {
    res.json({
        app: 'Simple Express.js App',
        version: '1.0.0',
        node_version: process.version,
        platform: process.platform,
        memory_usage: process.memoryUsage(),
        hostname: require('os').hostname(),
        timestamp: new Date().toISOString()
    });
});

app.get('/api/users', (req, res) => {
    const users = [
        { id: 1, name: 'John Doe', email: 'john@example.com' },
        { id: 2, name: 'Jane Smith', email: 'jane@example.com' },
        { id: 3, name: 'Bob Johnson', email: 'bob@example.com' }
    ];
    res.json({
        users: users,
        count: users.length,
        timestamp: new Date().toISOString()
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        error: 'Something went wrong!',
        timestamp: new Date().toISOString()
    });
});

// 404 handler
app.use('*', (req, res) => {
    res.status(404).json({
        error: 'Route not found',
        path: req.originalUrl,
        timestamp: new Date().toISOString()
    });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Express server running on port ${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`Hostname: ${require('os').hostname()}`);
    console.log(`Available routes:`);
    console.log(`  GET / - Welcome message`);
    console.log(`  GET /health - Health check`);
    console.log(`  GET /api/info - Application info`);
    console.log(`  GET /api/users - Sample users data`);
});

module.exports = app;