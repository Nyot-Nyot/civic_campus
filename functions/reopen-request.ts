import { createClient } from 'npm:@insforge/sdk';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export default async function (req: Request): Promise<Response> {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }

  const authHeader = req.headers.get('Authorization');
  const userToken = authHeader ? authHeader.replace('Bearer ', '') : null;
  if (!userToken) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }

  const client = createClient({
    baseUrl: Deno.env.get('INSFORGE_BASE_URL')!,
    edgeFunctionToken: userToken,
  });

  const { data: userData } = await client.auth.getCurrentUser();
  if (!userData?.user?.id) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }

  try {
    const body = await req.json();
    const { incident_id, reason, photo_storage_key } = body;

    if (!incident_id || !reason) {
      return new Response(
        JSON.stringify({ error: 'incident_id and reason are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const userId = userData.user.id;

    const reopenCountResp = await client.database
      .from('reopen_requests')
      .select('id', { count: 'exact' })
      .eq('requester_id', userId)
      .eq('incident_id', incident_id)
      .neq('status', 'Rejected');

    const reopenCount = typeof reopenCountResp.count === 'number' ? reopenCountResp.count : 0;
    if (reopenCount >= 2) {
      return new Response(
        JSON.stringify({ error: 'Maximum 2 reopen requests allowed per incident' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const incidentResp = await client.database
      .from('incidents')
      .select('id, title, status, reporter_id')
      .eq('id', incident_id)
      .single();

    if (incidentResp.error || !incidentResp.data) {
      return new Response(JSON.stringify({ error: 'Incident not found' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const incident = incidentResp.data;
    if (incident.status !== 'Resolved' && incident.status !== 'Closed') {
      return new Response(
        JSON.stringify({ error: 'Incident must be Resolved or Closed to request reopen' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const reopenResp = await client.database
      .from('reopen_requests')
      .insert([{
        incident_id,
        requester_id: userId,
        reason,
        photo_storage_key: photo_storage_key || null,
      }])
      .select('id')
      .single();

    if (reopenResp.error) {
      return new Response(JSON.stringify({ error: reopenResp.error.message }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const { data: adminProfiles } = await client.database
      .from('profiles')
      .select('id')
      .in('role', ['Facility Admin', 'Super Admin']);

    if (adminProfiles) {
      const notifications = adminProfiles.map((p: { id: string }) => ({
        user_id: p.id,
        type: 'reopen_requested',
        title: 'Permintaan Pembukaan Kembali',
        body: `Insiden "${incident.title}" meminta untuk dibuka kembali: ${reason}`,
        entity_type: 'incident',
        entity_id: incident_id,
      }));

      await client.database.from('notifications').insert(notifications);
    }

    return new Response(
      JSON.stringify({
        data: {
          reopen_id: reopenResp.data.id,
          status: 'Pending',
        },
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: e instanceof Error ? e.message : 'Internal error' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
}
