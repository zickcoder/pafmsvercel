import { createClient } from '@supabase/supabase-js';

const env = (import.meta as any).env || {};

const SUPABASE_URL = env.VITE_SUPABASE_URL || 'https://hxrzgnvzebvhqwewtvxz.supabase.co';
const SUPABASE_ANON_KEY = env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh4cnpnbnZ6ZWJ2aHF3ZXd0dnh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTIwNjIyMzgsImV4cCI6MjEwNzYzODIzOH0.QkszNeTdAu7NoRAqqChNxkcN5W7sILl5_57vPEVLOE8';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: { persistSession: false, autoRefreshToken: false }
});

export default supabase;
