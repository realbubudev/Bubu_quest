Config = {}

Config.StartNPC = {
    model = 's_m_y_dealer_01',
    coords = vector4(-1189.5128, -1581.8864, 3.3728, 208.3335)
}

Config.Abdi = {
    model = 'a_m_m_business_01',
    coords = vector4(-916.6390, -2595.7505, 15.7050, 143.6778)
}

Config.Bil = {
    model = 'sultan',
    spawnCoords = vector4(-915.9794, -2600.8914, 16.6050, 144.8117),
    returnDistance = 10.0
}

Config.RedZon = {
    coords = vector3(-921.1235, -2604.2705, 16.6050),
    radius = 120.0,
    duration = 1 * 60
}

Config.Cooldown = {
    job = 20 * 60,
    policeAlert = 60
}

Config.Reward = 5000

Config.Text = {
    start_job_label = 'Vill du göra ett updrag?',
    reward_label = 'Ta emot belöning',
    abdi_label = 'Snacka med Abdi',

    go_to_abdi = 'Följ gpsen, där väntar Abdi',
    start_hide = 'Göm dig med bilen inom det röda området annars kommer aina kunna tracka dig',
    return_reward = 'Skynda dig tillbaka, följ gpsen!',

    bil_missing = 'Fordonet finns inte här',
    bil_not_close = 'Fordonet måste stå nära',
    reward_received = 'Du tog emot belöningen!',

    cooldown = 'Du måste vänta %s minuter innan du kan göra updraget igen',

    RedZon_blip = 'Sökområde',

    police_alert = 'Misstänkt aktivitet rapporterad'
}