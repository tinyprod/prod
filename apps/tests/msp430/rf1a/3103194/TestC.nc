module TestC
{
    uses
    {
        interface SplitControl;
        interface Leds;
        interface Boot;
        interface AMSend;
        interface Receive;
	interface Timer<TMilli> as Timer;
    }
}

implementation
{
    bool m_locked = FALSE;
    message_t m_msg;

    event void Boot.booted()
    {
        call SplitControl.start();
    }

    event void SplitControl.startDone(error_t err)
    {
        call Timer.startPeriodic(30);
    }

    event void SplitControl.stopDone(error_t err)
    {
    }

    event void Timer.fired()
    {
        if( !m_locked )
        {
            m_locked = call AMSend.send(AM_BROADCAST_ADDR, &m_msg, 0) == SUCCESS;
        }
    }

    event message_t *Receive.receive(message_t *msg, void *payload, uint8_t len)
    {
        call Leds.led0Toggle();
        return msg;
    }

    event void AMSend.sendDone(message_t *msg, error_t error)
    {
        if( error == SUCCESS )
        {
            call Leds.led1Toggle();
        }

        m_locked = FALSE;
    }
}